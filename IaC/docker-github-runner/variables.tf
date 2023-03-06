variable "location" {
  type = string
  default = "switzerlandnorth"
}

variable "resourceGroupName" {
  type = string
}

variable "container-app-environment-id" {
  type = string
}

variable "container-app" {
  type = object({
    name = string
    image-name = string
    image = string
    tag = string
    secrets = list(object({
        name = string
        value = string
    }))
    env = list(object({
        name = string
        secretRef = optional(string)
        value = optional(string)
    }))
    registry = object({
        server = string
        username = string
        passwordSecretRef = string
    })
  })
}

variable "storage-name" {
  type = string
}