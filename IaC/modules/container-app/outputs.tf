output "container-app-principal-id" {
  value = azapi_resource.aca.identity.0.principal_id
}

output "container-app-fqdn" {
  value = jsondecode(azapi_resource.aca.output).properties.configuration.ingress.fqdn
}