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

# An endpoint is a logical grouping of one or more routes that are associated with domain names
resource "azurerm_cdn_frontdoor_endpoint" "fd" {
  name                     = var.endpoint-name
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.fd.id

  tags                     = var.tags
}

# resource "azurerm_cdn_frontdoor_origin" "fd" {
#   name                          = "${var.front-door-name}-origin"
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd.id
#   enabled                       = true

#   certificate_name_check_enabled = true # Required for Private Link
#   host_name                      = var.private-link-ip-address
#   origin_host_header             = var.private-link-ip-address
#   priority                       = 1
#   weight                         = 500

#   private_link {
#     request_message        = "Request access for CDN Frontdoor Private Link Origin Load Balancer"
#     location               = var.location
#     private_link_target_id = var.private-link-id
#   }
# }