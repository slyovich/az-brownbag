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

data "azapi_resource" "containerapp_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = var.containerAppEnvironment.name
  parent_id = data.azurerm_resource_group.landing-zone.id
  
  response_export_values  = ["id"]
}

module "blazor" {
  source = "../../modules/container-app"

  tags                           = local.tags
  location                       = var.location
  resourceGroupId                = data.azurerm_resource_group.rg.id

  container-app-environment-id   = jsondecode(data.azapi_resource.containerapp_environment.output).id

  container-app = {
    name = var.blazor.name
    image = var.image
    image-name = var.imageName
    tag = var.imageTag
    ingress = {
      external = false
      targetPort = 80
    }
    dapr = {
      enabled = true
      app_id = "blazorapp"
      app_port = 80
      app_protocol = "http"
    }
    cpu_requests = 0.75
    mem_requests = "1.5Gi"
    secrets = [ 
      {
          name = "gh-registry-token"
          value = var.githubRegistryToken
      }
    ]
    env = null
    registry = {
      server = var.blazor.registry.server
      username = var.blazor.registry.username
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
                  concurrentRequests = "50"
              }
          }
        }
      ]
    }
  }
}