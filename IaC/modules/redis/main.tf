resource "azurerm_redis_cache" "caching" {
  name                          = var.redis.name
  location                      = var.location
  resource_group_name           = var.resourceGroupName
  capacity                      = var.redis.sku.capacity
  family                        = var.redis.sku.family
  sku_name                      = var.redis.sku.name

  enable_non_ssl_port           = false
  minimum_tls_version           = "1.2"
  redis_version                 = 6

  public_network_access_enabled = false

  tags                          = var.tags
}

resource "azurerm_private_endpoint" "caching" {
  name                   = "peredisCache${replace(azurerm_redis_cache.caching.name, "-", "")}"
  location               = var.location
  resource_group_name    = var.resourceGroupName
  subnet_id              = var.redis.subnet-id
  
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.redis.dns-id]
  }

  private_service_connection {
    name                           = "plsrediscache${replace(azurerm_redis_cache.caching.name, "-", "")}"
    private_connection_resource_id = azurerm_redis_cache.caching.id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }
}