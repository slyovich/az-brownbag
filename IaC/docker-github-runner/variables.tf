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
        secretRef = string
        value = string
    }))
    registry = object({
        server = string
        username = string
        passwordSecretRef = string
    })
  })
  default = {
    env = [ {
      name = "value"
      secretRef = "value"
      value = "value"
    } ]
    image = "value"
    image-name = "value"
    name = "value"
    registry = {
      passwordSecretRef = "value"
      server = "value"
      username = "value"
    }
    secrets = [ {
      name = "value"
      value = "value"
    } ]
    tag = "value"
  }
}