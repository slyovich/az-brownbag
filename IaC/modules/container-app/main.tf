resource "azapi_resource" "aca" {
  type      = "Microsoft.App/containerApps@2022-03-01"
  parent_id = var.resourceGroupId
  location  = var.location
  name      = var.container-app.name
  
  body = jsonencode({
    properties: {
      managedEnvironmentId = var.container-app-environment-id
      configuration = {
        ingress = var.container-app.ingress
        dapr = {
          enabled = var.container-app.dapr.enabled
          appId =  var.container-app.dapr.enabled ? var.container-app.dapr.app_id : null
          appPort = var.container-app.dapr.enabled ? var.container-app.dapr.app_port : null
          appProtocol = var.container-app.dapr.enabled ? var.container-app.dapr.app_protocol : null
        }
        secrets = var.container-app.secrets
        registries = [
            {
                server = var.container-app.registry.server
                username = var.container-app.registry.username
                passwordSecretRef = var.container-app.registry.passwordSecretRef
            }
        ]
      }
      template = {
        containers = [
          {
            name = var.container-app.image-name
            image = "${var.container-app.image}:${var.container-app.tag}"
            env = var.container-app.env
            resources = {
              cpu = var.container-app.cpu_requests
              memory = var.container-app.mem_requests
            }
          }         
        ]
        scale = var.container-app.scale
      }
    }
  })
  
  identity {
    type = "SystemAssigned"
  }
  

  tags = var.tags
  
  response_export_values  = ["id", "properties.configuration.ingress.fqdn"]
  ignore_missing_property = true
}