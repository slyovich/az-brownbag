terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  
  backend "azurerm" { }
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
    Scope = "Application"
  }
}

# Create Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location

  tags = local.tags
}

#random_password.password.result
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "azurerm_subnet" "subnet" {
  name                 = var.sqlDb.subnet-name
  virtual_network_name = var.sqlDb.vnet-name
  resource_group_name  = var.sqlDb.vnet-rg
}

data "azurerm_private_dns_zone" "dns" {
  name                 = var.sqlDb.dns-name
  resource_group_name  = var.sqlDb.vnet-rg
}

data "azurerm_log_analytics_workspace" "example" {
  name                = var.sqlDb.workspace-name
  resource_group_name = var.sqlDb.vnet-rg
}