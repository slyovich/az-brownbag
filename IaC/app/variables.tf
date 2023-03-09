variable "location" {
  type = string
  default = "switzerlandnorth"
}

variable "resourceGroupName" {
  type = string
}

variable "sqlDb" {
  type = object({
    name = string
    server-name = string
    vnet-rg = string
    vnet-name = string
    subnet-name = string
    dns-name = string
    workspace-name = string
    admin = object({
        username = string
        object-id = string
    })
  })
}