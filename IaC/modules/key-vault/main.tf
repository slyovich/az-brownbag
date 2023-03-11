resource "azurerm_key_vault" "akv" {
    name                          = var.keyvault.name
    location                      = var.location
    resource_group_name           = var.resourceGroupName
    sku_name                      = "standard"
    tenant_id                     = var.keyvault.tenant-id
    enable_rbac_authorization     = true
    purge_protection_enabled      = true

    public_network_access_enabled = false

    tags                          = var.tags
}

resource "azurerm_private_endpoint" "akv" {
  name                   = "pevault${replace(azurerm_key_vault.akv.name, "-", "")}"
  location               = var.location
  resource_group_name    = var.resourceGroupName
  subnet_id              = var.keyvault.subnet-id
  
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.keyvault.dns-id]
  }

  private_service_connection {
    name                           = "plsvault${replace(azurerm_key_vault.akv.name, "-", "")}"
    private_connection_resource_id = azurerm_key_vault.akv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "akv" {
  name                          = "DiagLogAnalytics"
  target_resource_id            = azurerm_key_vault.akv.id
  log_analytics_workspace_id    = var.keyvault.workspace-id

  enabled_log {
    category = "AuditEvent"

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

resource "azurerm_role_assignment" "akv_role_assignment" {
  scope                = azurerm_key_vault.akv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.key-vault-default-officer-principal-id
}