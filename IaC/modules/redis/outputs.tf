output "connection-string" {
    value = azurerm_redis_cache.caching.primary_connection_string
}