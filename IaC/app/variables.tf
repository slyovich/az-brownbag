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
    dns-name = string
  })
}