resource "azurerm_mssql_server" "app-server" {
  name                                 = var.sql-db.server-name
  resource_group_name                  = var.resourceGroupName
  location                             = var.location
  version                              = "12.0"

  minimum_tls_version                  = "1.2"

  administrator_login                  = var.sql-db.admin.username
  administrator_login_password         = var.sql-db.admin.password

  public_network_access_enabled        = false
  outbound_network_restriction_enabled = true

  tags                                 = var.tags
}

resource "azurerm_private_endpoint" "app-server" {
  name                   = "pesqlserver${replace(azurerm_mssql_server.app-server.name, "-", "")}"
  location               = var.location
  resource_group_name    = var.resourceGroupName
  subnet_id              = var.sql-db.subnet-id
  
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.sql-db.dns-id]
  }

  private_service_connection {
    name                           = "plssqlserver${replace(azurerm_mssql_server.app-server.name, "-", "")}"
    private_connection_resource_id = azurerm_mssql_server.app-server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_mssql_database" "app-database" {
  name           = var.sql-db.name
  server_id      = azurerm_mssql_server.app-server.id
  
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = "Basic"

  zone_redundant = false

  tags           = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "app-database" {
  name                          = "DiagLogAnalytics"
  target_resource_id            = azurerm_mssql_database.app-database.id
  log_analytics_workspace_id    = var.sql-db.workspace-id

  enabled_log {
    category = "SQLInsights"

    retention_policy {
      days    = 0       # retain logs indifinitely
      enabled = false
    }
  }

  # ignore_changes is here given the bug I reported: https://github.com/terraform-providers/terraform-provider-azurerm/issues/10388
  lifecycle {
    ignore_changes = [enabled_log, metric]
  }
}