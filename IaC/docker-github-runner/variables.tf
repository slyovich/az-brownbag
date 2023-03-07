variable "location" {
  type = string
  default = "switzerlandnorth"
}

variable "resourceGroupName" {
  type = string
}

variable "containerAppEnvironmentName" {
  type = string
}

variable "containerApp" {
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

variable "storageName" {
  type = string
}