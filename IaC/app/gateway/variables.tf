variable "location" {
  type = string
  default = "switzerlandnorth"
}

variable "resourceGroupName" {
  type = string
}

variable "landingZone" {
  type = object({
    resource-group-name = string
    vnet-name = string
    subnet-name = string
    workspace-name = string
  })
}

variable "sqlDb" {
  type = object({
    name = string
    server-name = string
    dns-name = string
    admin = object({
        username = string
        object-id = string
    })
  })
}

variable "redis" {
  type = object({
    name = string
    sku = object({
        name = string
        family = string
        capacity = string
    })
    dns-name = string
  })
}

variable "containerAppEnvironment" {
  type = object({
    name  = string
    resource-group-name = string
  })
}

variable "githubRegistryToken" {
  type = string
  description = "Token used to fetch the container image from GitHub Packages"
}

variable "gatewayAppConfig" {
  type = object({
    client-id = string
    client-secret = string
    authority = string
    scopes = string
    backend-api-scope = string
  })
}

variable "gateway" {
  type = object({
    name = string
    image-name = string
    image = string
    tag = string
    registry = object({
        server = string
        username = string
    })
  })
}