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
    Scope = "Landing Zone"
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
  workspace-name      = var.workspaceName
  app-insight-name    = var.appInsightName

  depends_on = [
    azurerm_resource_group.rg
  ]
}

module "keyvault" {
  source = "../modules/key-vault"

  tags                                    = local.tags
  location                                = var.location
  resourceGroupName                       = var.resourceGroupName
  keyvault-name                           = var.keyVault.name
  subnet-id                               = module.vnet.subnet[var.keyVault.subnet-key].id
  dns-id                                  = module.vnet.dns-zones[var.keyVault.dns-key].id
  dns-name                                = module.vnet.dns-zones[var.keyVault.dns-key].name
  workspace-id                            = module.monitoring.workspace_id
  tenant-id                               = data.azurerm_client_config.current.tenant_id
  key-vault-default-officer-principal-id  = data.azurerm_client_config.current.object_id

  depends_on = [
    module.vnet,
    module.monitoring
  ]
}

module "container-app-environment" {
  source = "../modules/container-app-environment"

  tags                           = local.tags
  location                       = var.location
  resourceGroupId                = azurerm_resource_group.rg.id
  resourceGroupName              = azurerm_resource_group.rg.name
  environment-name               = var.containerAppEnvironment.name
  app-insights-connection-string = module.monitoring.app_insights_connection_string
  log-analytics-workspace-id     = module.monitoring.workspace_workspace_id
  log-analytics-workspace-key    = module.monitoring.workspace_key
  vnet-id                        = module.vnet.vnet_id
  subnet-id                      = module.vnet.subnet[var.containerAppEnvironment.subnet-key].id
  private-link-subnet-id         = module.vnet.subnet[var.containerAppEnvironment.private-link-subnet-key].id

  depends_on = [
    module.vnet,
    module.monitoring
  ]
}

data "azurerm_private_link_service" "container-app-environment" {
  name                = module.container-app-environment.private-link-name
  resource_group_name = var.resourceGroupName

  depends_on = [
    module.container-app-environment
  ]
}

module "front-door" {
  source = "../modules/front-door"

  tags                           = local.tags
  location                       = var.location
  resourceGroupName              = azurerm_resource_group.rg.name
  front-door-name                = var.frontDoor.name
  custom-domain-name             = var.frontDoor.custom-domain-name
  private-link-id                = data.azurerm_private_link_service.container-app-environment.id
  private-link-ip-address        = data.azurerm_private_link_service.container-app-environment.nat_ip_configuration[0].private_ip_address

  depends_on = [
    module.container-app-environment
  ]
}