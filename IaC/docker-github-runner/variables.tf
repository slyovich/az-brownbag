variable "location" {
  type = string
  default = "switzerlandnorth"
}

variable "resourceGroupName" {
  type = string
}

variable "containerAppEnvironment" {
  type = object({
    name  = string
    resource-group-name = string
  })
}

variable "containerApp" {
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

variable "githubRunnerToken" {
  type = string
  description = "Token used to identify the runner within GitHub"
}

variable "githubRegistryToken" {
  type = string
  description = "Token used to fetch the container image from GitHub Packages"
}

variable "storageName" {
  type = string
}