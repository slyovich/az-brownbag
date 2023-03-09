output "container-app-principal-id" {
  value = jsondecode(azapi_resource.aca.output).identity.principalId
}