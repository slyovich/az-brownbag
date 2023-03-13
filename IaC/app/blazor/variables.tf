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

variable "blazor" {
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