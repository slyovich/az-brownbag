variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resourceGroupId" {
  type = string
}

variable "container-app-environment-id" {
  type = string
}

variable "container-apps" {
  type = list(object({
    name = string
    image-name = string
    image = string
    tag = string
    ingress = object({
      external = bool
      targetPort = number
    })
    dapr_enabled = bool
    dapr_app_id = string
    dapr_app_port = number
    dapr_app_protocol = string  //http or grpc
    min_replicas = number
    max_replicas = number
    cpu_requests = number
    mem_requests = string
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
  }))
}