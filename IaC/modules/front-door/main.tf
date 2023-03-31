resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                     = var.front-door-name
  resource_group_name      = var.resourceGroupName
  sku_name                 = "Premium_AzureFrontDoor"

  response_timeout_seconds = 120

  tags                     = var.tags
}

resource "azurerm_dns_zone" "fd" {
  count = var.custom-domain-name != null ? 1 : 0

  name                = var.custom-domain-name
  resource_group_name = var.resourceGroupName
}

resource "azurerm_cdn_frontdoor_custom_domain" "fd" {
  count = var.custom-domain-name != null ? 1 : 0

  name                     = "${replace(var.custom-domain-name, ".", "-")}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  dns_zone_id              = azurerm_dns_zone.fd[count.index].id
  host_name                = var.custom-domain-name

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_dns_txt_record" "fd" {
  count = var.custom-domain-name != null ? 1 : 0

  name                = "_dnsauth"
  zone_name           = azurerm_dns_zone.fd[count.index].name
  resource_group_name = var.resourceGroupName
  ttl                 = 3600

  record {
    value = azurerm_cdn_frontdoor_custom_domain.fd[count.index].validation_token
  }
}

# An endpoint is a logical grouping of one or more routes that are associated with domain names
resource "azurerm_cdn_frontdoor_endpoint" "fd" {
  name                     = "${var.front-door-name}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id

  tags                     = var.tags
}