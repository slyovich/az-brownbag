output "container-app-environment-id" {
  value = jsondecode(azapi_resource.containerapp_environment.output).id
}