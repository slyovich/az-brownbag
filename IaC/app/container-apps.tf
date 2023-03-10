module "apps" {
  module = "../module/container-app"

  tags                           = local.tags
  location                       = var.location
  resourceGroupId                = azurerm_resource_group.id

  container-app-environment-id   = jsondecode(data.azapi_resource.containerapp_environment.output).id

  container-apps = [
    #gateway
    {
      name = var.gateway.name
      image = var.gateway.image
      image-name = var.gateway.image-name
      tag = var.gateway.tag
      ingress = {
        external = true
        targetPort = 80
      }
      dapr = {
        enabled = true
        app_id = "gateway"
        app_port = 80
        app_protocol = "http"
      }
      cpu_requests = 0.75
      mem_requests = "1.5Gi"
      secrets = [ 
        {
            name = "gh-registry-token"
            value = var.githubRegistryToken
        },
        {
            name = "client-secret"
            value = var.gatewayAppConfig.client-secret
        },
        {
            name = "redis-connection-string"
            value = module.redis.connection-string
        }
      ]
      env = [ 
        {
            name = "OpenIdConnect__Authority"
            value = var.gatewayAppConfig.authority
        },
        {
            name = "OpenIdConnect__ClientId"
            value = var.gatewayAppConfig.client-id
        },
        {
            name = "OpenIdConnect__ClientSecret"
            secretRef = "client-secret"
        },
        {
            name = "OpenIdConnect__Scopes"
            value = var.gatewayAppConfig.scopes
        },
        {
            name = "Apis__0__ApiScopes"
            value = var.gatewayAppConfig.backend-api-scope
        },
        {
            name = "ReverseProxy__Clusters__blazorapp__Destinations__destination1__Address"
            value = "http://localhost:3500"
        },
        {
            name = "ReverseProxy__Clusters__webapi__Destinations__destination1__Address"
            value = "http://localhost:3500"
        },
        {
            name = "Redis__InstanceName"
            value = var.redis.name
        },
        {
            name = "Redis__ConnectionString"
            secretRef = "redis-connection-string"
        }
      ]
      registry = {
        server = var.gateway.registry.server
        username = var.gateway.registry.username
        passwordSecretRef = "gh-registry-token"
      }
      scale = {
        minReplicas = 0
        maxReplicas = 3
        rules = [
          {
            name = "http-scaling"
            http = {
                metadata = {
                    concurrentRequests = 50
                }
            }
          }
        ]
      }
    }
  ]

  depends_on = [
    module.redis
  ]
}