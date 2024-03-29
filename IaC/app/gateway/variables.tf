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
    authority = string
    scopes = string
    backend-api-scope = string
  })
}

variable "gatewayClientSecret" {
  type = string
}

variable "gateway" {
  type = object({
    name = string
    registry = object({
        server = string
        username = string
    })
  })
}

variable "imageName" {
  type = string
}

variable "image" {
  type = string
}

variable "imageTag" {
  type = string
}

variable "frontDoor" {
  type = object({
    name               = string
    custom-domain-name = string
  })
}