output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
}

output "subnet" {
    value = azurerm_subnet.subnets
}

output "dns-zones" {
    value = azurerm_private_dns_zone.dns-zones
}