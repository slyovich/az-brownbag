resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                = var.front-door-name
  resource_group_name = var.resourceGroupName
  sku_name            = "Premium_AzureFrontDoor"

  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_custom_domain" "fd" {
  count = var.custom-domain-name != null ? 1 : 0

  name                     = "example-customDomain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  host_name                = var.custom-domain-name

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}