resource "azapi_resource" "aca" {
  for_each  = { for ca in var.container-apps: ca.name => ca}
  type      = "Microsoft.App/containerApps@2022-03-01"
  parent_id = var.resourceGroupId
  location  = var.location
  name      = each.value.name
  
  body = jsonencode({
    properties: {
      managedEnvironmentId = var.container-app-environment-id
      configuration = {
        ingress = each.value.ingress
        dapr = {
          enabled = each.value.dapr.enabled
          appId =  each.value.dapr.enabled ? each.value.dapr.app_id : null
          appPort = each.value.dapr.enabled ? each.value.dapr.app_port : null
          appProtocol = each.value.dapr.enabled ? each.value.dapr.app_protocol : null
        }
        secrets = each.value.secrets
        registries = [
            {
                server = each.value.registry.server
                username = each.value.registry.username
                passwordSecretRef = each.value.registry.passwordSecretRef
            }
        ]
      }
      template = {
        containers = [
          {
            name = each.value.image-name
            image = "${each.value.image}:${each.value.tag}"
            env = each.value.env
            resources = {
              cpu = each.value.cpu_requests
              memory = each.value.mem_requests
            }
          }         
        ]
        scale = each.value.scale
      }
    }
  })
  
  identity {
    type = "SystemAssigned"
  }
  

  tags = var.tags
  
  ignore_missing_property = true
}