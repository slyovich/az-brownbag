locals {
  nsgRules = flatten([
    for nsg_key, nsg in var.nsg : [
      for rule in nsg.rules : {
        nsgName                    = nsg.name
        name                       = rule.name
        priority                   = rule.priority
        direction                  = rule.direction
        access                     = rule.access
        protocol                   = rule.protocol
        source_port_range          = rule.source_port_range
        destination_port_range     = rule.destination_port_range
        source_address_prefix      = rule.source_address_prefix
        destination_address_prefix = rule.destination_address_prefix
      }
    ]
  ])
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = var.vnet.address_space

  tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
  for_each              = var.nsg

  name                  = each.value.name
  location              = var.location
  resource_group_name   = var.resourceGroupName
  tags                  = var.tags
}

resource "azurerm_network_security_rule" "nsg-rules" {
  # Each instance must have a unique key, so we'll construct one
  for_each = {
    for ns in local.nsgRules  : "${ns.nsgName}.${ns.direction}.${ns.name}" => ns
  }

  name                        = each.value.name
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resourceGroupName
  network_security_group_name = each.value.nsgName

  depends_on = [
    azurerm_network_security_group.nsg
  ]
}

resource "azurerm_subnet" "subnets" {
  for_each                                        = var.subnets
  
  resource_group_name                             = var.resourceGroupName
  virtual_network_name                            = azurerm_virtual_network.vnet.name
  name                                            = each.value.name
  address_prefixes                                = each.value.address_space

  private_endpoint_network_policies_enabled       = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled   = each.value.private_link_service_network_policies_enabled

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  for_each                  = var.subnets

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

  depends_on = [
    azurerm_network_security_group.nsg,
    azurerm_subnet.subnets
  ]
}

resource "azurerm_private_dns_zone" "dns-zones" {
  for_each                  = var.dns

  name                      = each.value.name
  resource_group_name       = var.resourceGroupName

  tags                      = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns-zones-links" {
  for_each                  = var.dns
  
  name                      = each.key
  resource_group_name       = var.resourceGroupName
  private_dns_zone_name     = each.value.name
  virtual_network_id        = azurerm_virtual_network.vnet.id

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_private_dns_zone.dns-zones
  ]
}