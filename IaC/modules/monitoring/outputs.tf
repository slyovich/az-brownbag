output "app_insights_connection_string" {
  value = azurerm_application_insights.insight.connection_string
}

output "workspace_key" {
    value = azurerm_log_analytics_workspace.workspace.primary_shared_key
}

output "workspace_workspace_id" {
    value = azurerm_log_analytics_workspace.workspace.workspace_id
}

output "workspace_id" {
    value = azurerm_log_analytics_workspace.workspace.id
}