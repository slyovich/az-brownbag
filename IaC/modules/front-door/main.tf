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
}^

resource "azurerm_cdn_frontdoor_origin_group" "fd" {
  name                     = "${var.front-door-name}-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  session_affinity_enabled = false

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10

  health_probe {
    interval_in_seconds = 60
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

# An endpoint is a logical grouping of one or more routes that are associated with domain names
resource "azurerm_cdn_frontdoor_endpoint" "fd" {
  name                     = "${var.front-door-name}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id

  tags                     = var.tags
}


# resource "azurerm_cdn_frontdoor_route" "fd" {
#   name                          = "${var.front-door-name}-route"
#   cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd.id
#   cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd.id
#   cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.example.id]
#   cdn_frontdoor_rule_set_ids    = [azurerm_cdn_frontdoor_rule_set.example.id]
#   enabled                       = true

#   forwarding_protocol    = "HttpsOnly"
#   https_redirect_enabled = true
#   patterns_to_match      = ["/*"]
#   supported_protocols    = ["Http", "Https"]

#   cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.contoso.id, azurerm_cdn_frontdoor_custom_domain.fabrikam.id]
#   link_to_default_domain          = false

#   cache {
#     query_string_caching_behavior = "IgnoreSpecifiedQueryStrings"
#     query_strings                 = ["account", "settings"]
#     compression_enabled           = true
#     content_types_to_compress     = ["text/html", "text/javascript", "text/xml"]
#   }
# }

# resource "azurerm_cdn_frontdoor_custom_domain_association" "fd_route" {
#   count = var.custom-domain-name != null ? 1 : 0

#   cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.fd[count.index].id
#   cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.fd.id]
# }

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