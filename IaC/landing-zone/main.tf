terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  storage_use_azuread = true    # Allow access to storage with shared_access_key disabled
  features {}
}

# Use this data source to access the configuration of the AzureRM provider
# https://registry.terraform.io/providers/hashicorp/azurerm/1.38.0/docs/data-sources/client_config
data "azurerm_client_config" "current" {}

locals {
  tags = {
    Application = "demo"
    Scope = "PoC"
  }
}

# Create Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location

  tags = local.tags
}

module "vnet" {
  source = "../modules/virtual-network"

  tags                = local.tags
  location            = var.location
  resourceGroupName   = var.resourceGroupName
  vnet                = var.vnet
  nsg                 = var.nsg
  subnets             = var.subnets
  dns                 = var.dns

  depends_on = [
    azurerm_resource_group.rg
  ]
}

module "monitoring" {
  source = "../modules/monitoring"

  tags                = local.tags
  location            = var.location
  resourceGroupName   = var.resourceGroupName
  workspace-name      = var.workspace-name
  app-insight-name    = var.app-insight-name

  depends_on = [
    azurerm_resource_group.rg
  ]
}

module "keyvault" {
  source = "../modules/key-vault"

  tags                                    = local.tags
  location                                = var.location
  resourceGroupName                       = var.resourceGroupName
  keyvault-name                           = var.key-vault.name
  subnet-id                               = module.vnet.subnet[var.key-vault.subnet-key].id
  dns-id                                  = module.vnet.dns-zones[var.key-vault.dns-key].id
  dns-name                                = module.vnet.dns-zones[var.key-vault.dns-key].name
  workspace-id                            = module.monitoring.workspace_id
  tenant-id                               = data.azurerm_client_config.current.tenant_id
  key-vault-default-officer-principal-id  = data.azurerm_client_config.current.object_id

  depends_on = [
    module.vnet,
    module.monitoring
  ]
}