output "container-app-principal-id" {
  value = azapi_resource.aca.identity.0.principalId
}