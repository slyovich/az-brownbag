terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azapi = {
      source  = "azure/azapi"
    }
  }
  
  backend "azurerm" { }
}

provider "azurerm" {
  storage_use_azuread = true    # Allow access to storage with shared_access_key disabled
  features {}
}

provider "azapi" { }

locals {
  tags = {
    Application = "demo"
    Scope = "Application"
  }
}

# Get current Resource group
data "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
}

# Get landing zone Resource group
data "azurerm_resource_group" "landing-zone" {
  name     = var.landingZone.resource-group-name
}

data "azurerm_redis_cache" "caching" {
  name                = var.redis.name
  resource_group_name = var.resourceGroupName
}

data "azapi_resource" "containerapp_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = var.containerAppEnvironment.name
  parent_id = data.azurerm_resource_group.landing-zone.id
  
  response_export_values  = ["id"]
}

data "azurerm_private_link_service" "containerapp_privatelink" {
  name                = "pl${replace(var.containerAppEnvironment.name, "-", "")}"
  resource_group_name = data.azurerm_resource_group.landing-zone.id
}

module "gateway" {
  source = "../../modules/container-app"

  tags                           = local.tags
  location                       = var.location
  resourceGroupId                = data.azurerm_resource_group.rg.id

  container-app-environment-id   = jsondecode(data.azapi_resource.containerapp_environment.output).id

  container-app = {
    name = var.gateway.name
    image = var.image
    image-name = var.imageName
    tag = var.imageTag
    ingress = {
      external = true
      targetPort = 80
    }
    dapr = {
      enabled = true
      app_id = "gateway"
      app_port = 80
      app_protocol = "http"
    }
    cpu_requests = 0.75
    mem_requests = "1.5Gi"
    secrets = [ 
      {
          name = "gh-registry-token"
          value = var.githubRegistryToken
      },
      {
          name = "client-secret"
          value = var.gatewayClientSecret
      },
      {
          name = "redis-connection-string"
          value = data.azurerm_redis_cache.caching.primary_connection_string
      }
    ]
    env = [ 
      {
          name = "OpenIdConnect__Authority"
          value = var.gatewayAppConfig.authority
      },
      {
          name = "OpenIdConnect__ClientId"
          value = var.gatewayAppConfig.client-id
      },
      {
          name = "OpenIdConnect__ClientSecret"
          secretRef = "client-secret"
      },
      {
          name = "OpenIdConnect__Scopes"
          value = var.gatewayAppConfig.scopes
      },
      {
          name = "Apis__0__ApiScopes"
          value = var.gatewayAppConfig.backend-api-scope
      },
      {
          name = "ReverseProxy__Clusters__blazorapp__Destinations__destination1__Address"
          value = "http://localhost:3500"
      },
      {
          name = "ReverseProxy__Clusters__webapi__Destinations__destination1__Address"
          value = "http://localhost:3500"
      },
      {
          name = "Redis__InstanceName"
          value = var.redis.name
      },
      {
          name = "Redis__ConnectionString"
          secretRef = "redis-connection-string"
      }
    ]
    registry = {
      server = var.gateway.registry.server
      username = var.gateway.registry.username
      passwordSecretRef = "gh-registry-token"
    }
    scale = {
      minReplicas = 0
      maxReplicas = 3
      rules = [
        {
          name = "http-scaling"
          http = {
              metadata = {
                  concurrentRequests = 50
              }
          }
        }
      ]
    }
  }
}

module "front-door-route" {
  source = "../../modules/front-door-route"

  tags                           = local.tags
  location                       = var.location
  resourceGroupName              = data.azurerm_resource_group.landing-zone.name

  front-door-name                = var.frontDoor.name
  custom-domain-name             = var.frontDoor.custom-domain-name

  private-link-id                = data.azurerm_private_link_service.containerapp_privatelink.id

  origin-name                    = "gateway"
  origin-host                    = module.gateway.container-app-fqdn
}