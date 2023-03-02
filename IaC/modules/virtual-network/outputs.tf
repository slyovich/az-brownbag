output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
}

output "subnet" {
    value = zipmap( values(azurerm_subnet.subnets)[*].name, values(azurerm_subnet.subnets)[*].id )
}