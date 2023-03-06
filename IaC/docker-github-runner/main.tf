terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azapi = {
      source  = "azure/azapi"
    }
  }

  // https://servian.dev/terraform-optional-variables-and-attributes-using-null-and-optional-flag-62c5cd88f9ca
  experiments = [module_variable_optional_attrs]
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
    Scope = "PoC"
    Description = "GitHub Runner"
  }
  queueName = "gh-runner-scaler"
}

# Get Resource group
data "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
}

module "storage" {
  source = "../modules/storage-account"

  tags                           = local.tags
  location                       = var.location
  resourceGroupName              = data.azurerm_resource_group.rg.name
  storage = {
    name = var.storage-name
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
  resourceGroupId                = data.azurerm_resource_group.rg.id
  container-app-environment-id   = var.container-app-environment-id
  container-apps = [
    {
      name = var.container-app.name
      image = var.container-app.image
      image-name = var.container-app.image-name
      tag = var.container-app.tag
      ingress = null
      dapr_enabled = false
      dapr_app_id = null
      dapr_app_port = null
      dapr_app_protocol = null
      cpu_requests = 1.75
      mem_requests = "3.5Gi"
      secrets = setunion(
        var.container-app.secrets,
        [
          {
            name = "storage-connection-string"
            value = module.storage.storage-connection-string
          }
        ])
      env = var.container-app.env
      registry = var.container-app.registry
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
  ]

  depends_on = [
    module.storage
  ]
}