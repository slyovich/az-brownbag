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
    })
  })
}

variable "sqlDbAdminPassword" {
  type = string
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