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

# Use this data source to access the configuration of the AzureRM provider
# https://registry.terraform.io/providers/hashicorp/azurerm/1.38.0/docs/data-sources/client_config
data "azurerm_client_config" "current" {}

locals {
  tags = {
    Application = "demo"
    Scope = "GitHub Runner"
  }
  queueName = "gh-runner-scaler"
}

# Create Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location

  tags = local.tags
}

data "azurerm_resource_group" "landing-zone" {
  name    = var.containerAppEnvironment.resource-group-name
}

data "azapi_resource" "containerapp_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = var.containerAppEnvironment.name
  parent_id = data.azurerm_resource_group.landing-zone.id
  
  response_export_values  = ["id"]
}

module "storage" {
  source = "../modules/storage-account"

  tags                           = local.tags
  location                       = var.location
  resourceGroupName              = azurerm_resource_group.rg.name
  storage = {
    name = var.storageName
    replication_type = "LRS"
    access_tier = "Hot"
    public_access = true
    is_hns = false
    access_key_enabled = true
  }
  private-endpoint = null
  queues = {
    gh-runner = local.queueName
  }
  role-assignments = [
    {
      principal-id = data.azurerm_client_config.current.object_id
      role = "Storage Queue Data Contributor"
    }
  ]
}

module "github-runner" {
  source = "../modules/container-app"

  tags                           = local.tags
  location                       = var.location
  resourceGroupId                = azurerm_resource_group.rg.id
  container-app-environment-id   = jsondecode(data.azapi_resource.containerapp_environment.output).id
  container-app = {
    name = var.containerApp.name
    image = var.containerApp.image
    image-name = var.containerApp.image-name
    tag = var.containerApp.tag
    ingress = null
    dapr = {
      enabled = false
      app_id = null
      app_port = null
      app_protocol = null
    }
    cpu_requests = 1.75
    mem_requests = "3.5Gi"
    secrets = [ 
      {
          name = "gh-token"
          value = var.githubRunnerToken
      },
      {
          name = "gh-registry-token"
          value = var.githubRegistryToken
      },
      {
          name = "storage-connection-string"
          value = module.storage.storage-connection-string
      }
    ]
    env = [ 
      {
          name = "GH_OWNER"
          value = "slyovich"
      },
      {
          name = "GH_REPOSITORY"
          value = "az-brownbag"
      },
      {
          name = "GH_TOKEN"
          secretRef = "gh-token"
      }
    ]
    registry = {
      server = var.containerApp.registry.server
      username = var.containerApp.registry.username
      passwordSecretRef = "gh-registry-token"
    }
    scale = {
      minReplicas = 0
      maxReplicas = 3
      rules = [
        {
          name = "queue-scaling"
          azureQueue = {
            queueName = local.queueName
            queueLength = 1
            auth = [
              {
                secretRef = "storage-connection-string"
                triggerParameter = "connection"
              }
            ]
          }
        }
      ]
    }
  }

  depends_on = [
    module.storage
  ]
}