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
    Scope = "Application"
  }
}

# Create Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location

  tags = local.tags
}

data "azurerm_subnet" "private-endpoint-subnet" {
  name                 = var.landingZone.subnet-name
  virtual_network_name = var.landingZone.vnet-name
  resource_group_name  = var.landingZone.resource-group-name
}

data "azurerm_private_dns_zone" "sql-dns" {
  name                 = var.sqlDb.dns-name
  resource_group_name  = var.landingZone.resource-group-name
}

data "azurerm_private_dns_zone" "redis-dns" {
  name                 = var.redis.dns-name
  resource_group_name  = var.landingZone.resource-group-name
}

data "azurerm_log_analytics_workspace" "logs" {
  name                = var.landingZone.workspace-name
  resource_group_name = var.landingZone.resource-group-name
}

module "redis" {
  source = "../modules/redis"

  tags                           = local.tags
  location                       = var.location
  resourceGroupName              = azurerm_resource_group.rg.name

  redis = {
    name = var.redis.name
    sku = var.redis.sku
    subnet-id = data.azurerm_subnet.private-endpoint-subnet.id
    dns-id = data.azurerm_private_dns_zone.redis-dns.id
  }
}

module "sql" {
  source = "../modules/sql-db"

  tags                           = local.tags
  location                       = var.location
  resourceGroupName              = azurerm_resource_group.rg.name

  sql-db = {
    name = var.sqlDb.name
    server-name = var.sqlDb.server-name
    
    subnet-id = azurerm_subnet.private-endpoint-subnet.id
    dns-id = azurerm_private_dns_zone.sql-dns.id
    workspace-id = azurerm_log_analytics_workspace.logs.id

    admin = {
      username = var.sqlDb.admin.username
      password = var.sqlDbAdminPassword
    }
  }
}