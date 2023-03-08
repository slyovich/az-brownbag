resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                     = var.front-door-name
  resource_group_name      = var.resourceGroupName
  sku_name                 = "Premium_AzureFrontDoor"

  response_timeout_seconds = 120

  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_custom_domain" "fd" {
  count = var.custom-domain-name != null ? 1 : 0

  name                     = "${replace(var.custom-domain-name, ".", "_")}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  host_name                = var.custom-domain-name

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

# resource "azurerm_cdn_frontdoor_origin_group" "fd" {
#   name                     = "${var.front-door-name}-origin-group"
#   cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
#   session_affinity_enabled = false

#   restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 10

#   health_probe {
#     interval_in_seconds = 100
#     path                = "/"
#     protocol            = "Https"
#     request_type        = "HEAD"
#   }

#   load_balancing {
#     additional_latency_in_milliseconds = 50
#     sample_size                        = 16
#     successful_samples_required        = 10
#   }
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