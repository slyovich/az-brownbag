resource "azurerm_storage_account" "storage" {
  name                             = var.storage.name
  resource_group_name              = var.resourceGroupName
  location                         = var.location
  account_tier                     = "Standard"
  account_replication_type         = var.storage.replication_type
  account_kind                     = "StorageV2"
  access_tier                      = var.storage.access_tier

  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"

  cross_tenant_replication_enabled = false
  allow_blob_public_access         = false
  shared_access_key_enabled        = false
  is_hns_enabled                   = var.storage.is_hns

  public_network_access_enabled    = var.storage.public_access

  tags                             = var.tags
}

resource "azurerm_storage_queue" "storage" {
  for_each             = var.queues

  name                 = each.value
  storage_account_name = azurerm_storage_account.storage.name
}

resource "azurerm_private_endpoint" "storage" {
  count = var.private-endpoint != null ? 1 : 0

  name                   = "pefile${replace(azurerm_storage_account.storage.name, "-", "")}"
  location               = var.location
  resource_group_name    = var.resourceGroupName
  subnet_id              = var.private-endpoint.subnet-id

  tags                   = var.tags
  
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private-endpoint.dns-id]
  }

  private_service_connection {
    name                           = "plsfile${replace(azurerm_storage_account.storage.name, "-", "")}"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = [var.private-endpoint.subresource]
  }
}

resource "azurerm_role_assignment" "akv_role_assignment" {
  for_each = var.role-assignments

  scope                = azurerm_storage_account.storage.id
  role_definition_name = each.value.role
  principal_id         = each.value.principal-id
}