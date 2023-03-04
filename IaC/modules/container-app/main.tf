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
        ingress = {
          external = each.value.ingress_enabled
          targetPort = each.value.ingress_enabled ? each.value.containerPort : null
        }
        dapr = {
          enabled = each.value.dapr_enabled
          appId =  each.value.dapr_enabled ? each.value.dapr_app_id : null
          appPort = each.value.dapr_enabled ? each.value.dapr_app_port : null
          appProtocol = each.value.dapr_enabled ? each.value.dapr_app_protocol : null
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
        scale = {
          minReplicas = each.value.min_replicas
          maxReplicas = each.value.max_replicas
        }
      }
    }
  })

  tags = local.tags
}