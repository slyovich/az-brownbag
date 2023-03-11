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
    dapr = object({
      enabled = bool
      app_id = string
      app_port = number
      app_protocol = string  //http or grpc  
    })
    cpu_requests = number
    mem_requests = string
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
    scale = object({
      minReplicas = number
      maxReplicas = number
      rules = list(object(
        {
          name = string
          azureQueue = optional(object({
            auth = list(object(
              {
                secretRef = string
                triggerParameter = string
              }
            ))
            queueLength = number
            queueName = string
          }))
          custom = optional(object({
            auth = list(object(
              {
                secretRef = string
                triggerParameter = string
              }
            ))
            type = string
          }))
          http = optional(object({
            auth = list(object(
              {
                secretRef = string
                triggerParameter = string
              }
            ))
            metadata = object({
              concurrentRequests = number
            })
          }))
        }
      ))
    })
  }))
}