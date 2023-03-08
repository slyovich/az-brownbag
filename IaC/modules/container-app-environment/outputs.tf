output "container-app-environment-id" {
  value = jsondecode(azapi_resource.containerapp_environment.output).id
}

output "private-link-id" {
  value = azurerm_private_link_service.container_app_environment.id
}

output "private-link-name" {
  value = azurerm_private_link_service.container_app_environment.id
}

output "private-link-ip-address" {
  value = azurerm_private_link_service.container_app_environment.nat_ip_configuration[0].private_ip_address
}