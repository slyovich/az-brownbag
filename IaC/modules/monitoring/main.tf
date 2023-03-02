resource "azurerm_log_analytics_workspace" "workspace" {
  name                       = var.workspace-name
  location                   = var.location
  resource_group_name        = var.resourceGroupName
  sku                        = "PerGB2018"
  retention_in_days          = 30

  internet_ingestion_enabled = true  //If false, must have a private link
  internet_query_enabled     = true  //If false, must have a private link

  tags                       = var.tags
}

resource "azurerm_application_insights" "insight" {
  name                       = var.app-insight-name
  location                   = var.location
  resource_group_name        = var.resourceGroupName
  workspace_id               = azurerm_log_analytics_workspace.workspace.id
  application_type           = "web"

  internet_ingestion_enabled = true  //If false, must have a private link
  internet_query_enabled     = true  //If false, must have a private link

  tags                       = var.tags
}