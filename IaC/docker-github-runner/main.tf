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
}

provider "azurerm" {
  storage_use_azuread = true    # Allow access to storage with shared_access_key disabled
  features {}
}

provider "azapi" { }

locals {
  tags = {
    Application = "demo"
    Scope = "PoC"
  }
}

# Get Resource group
data "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
}

module "github-runner" {
  source = "../modules/container-app"

  tags                           = local.tags
  location                       = var.location
  resourceGroupId                = data.azurerm_resource_group.rg.id
  container-app-environment-id   = var.container-app-environment-id
  container-apps = [ {
    name = var.container-app.name
    image = var.container-app.image
    image-name = var.container-app.image-name
    tag = var.container-app.tag
    containerPort = null
    ingress_enabled = false
    dapr_enabled = false
    dapr_app_id = null
    dapr_app_port = null
    dapr_app_protocol = null
    min_replicas = 0
    max_replicas = 3
    cpu_requests = 1.75
    mem_requests = "3.5Gi"
    secrets = var.container-app.secrets
    env = var.container-app.env
    registry = var.container-app.registry
  } ]
}