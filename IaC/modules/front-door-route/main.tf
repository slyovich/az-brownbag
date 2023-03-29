data "azurerm_cdn_frontdoor_profile" "fd" {
  name                     = var.front-door-name
  resource_group_name      = var.resourceGroupName
}

data "azurerm_cdn_frontdoor_endpoint" "fd" {
  name                     = "${var.front-door-name}-endpoint"
  profile_name             = var.front-door-name
  resource_group_name      = var.resourceGroupName
}

data "azurerm_cdn_frontdoor_origin_group" "fd" {
  name                     = "${var.front-door-name}-origin-group"
  profile_name             = var.front-door-name
  resource_group_name      = var.resourceGroupName
}

data "azurerm_cdn_frontdoor_custom_domain" "fd" {
  count = var.custom-domain-name != null ? 1 : 0

  name                     = "${replace(var.custom-domain-name, ".", "-")}"
  profile_name             = var.front-door-name
  resource_group_name      = var.resourceGroupName
}

resource "azurerm_cdn_frontdoor_origin" "fd" {
  name                          = var.origin-name
  cdn_frontdoor_origin_group_id = data.azurerm_cdn_frontdoor_origin_group.fd.id
  enabled                       = true

  certificate_name_check_enabled = true # Required for Private Link
  host_name                      = var.origin-host
  origin_host_header             = var.origin-host
  priority                       = 1
  weight                         = 500

  http_port                      = 80
  https_port                     = 443

  private_link {
    request_message        = "Request access for CDN Frontdoor Private Link Origin Load Balancer"
    location               = var.location
    private_link_target_id = var.private-link-id
  }
}

resource "azurerm_cdn_frontdoor_route" "fd" {
  name                          = "${var.front-door-name}-route"
  cdn_frontdoor_endpoint_id     = data.azurerm_cdn_frontdoor_endpoint.fd.id
  cdn_frontdoor_origin_group_id = data.azurerm_cdn_frontdoor_origin_group.fd.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fd.id]
  enabled                       = true

  cdn_frontdoor_custom_domain_ids = var.custom-domain-name != null ? [data.azurerm_cdn_frontdoor_custom_domain.fd[0].id] : null
  link_to_default_domain          = var.custom-domain-name != null ? false : true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cache {
    query_string_caching_behavior = "IgnoreQueryString"
    compression_enabled           = true
    content_types_to_compress     = ["text/html", "text/javascript", "text/xml"]
  }
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "fd_route" {
  count = var.custom-domain-name != null ? 1 : 0

  cdn_frontdoor_custom_domain_id = data.azurerm_cdn_frontdoor_custom_domain.fd[count.index].id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.fd.id]
}

resource "azurerm_dns_cname_record" "fd" {
  count = var.custom-domain-name != null ? 1 : 0
  
  name                = var.origin-name
  zone_name           = var.custom-domain-name
  resource_group_name = var.resourceGroupName
  ttl                 = 300
  record              = data.azurerm_cdn_frontdoor_endpoint.fd.host_name
}