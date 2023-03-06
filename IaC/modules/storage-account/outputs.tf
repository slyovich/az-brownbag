output "storage-id" {
  value = azurerm_storage_account.storage.id
}

output "storage-connection-string" {
  value = azurerm_storage_account.storage.primary_connection_string
}