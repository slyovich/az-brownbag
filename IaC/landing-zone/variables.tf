variable "location" {
  type = string
  default = "switzerlandnorth"
}

variable "resourceGroupName" {
  type = string
}

variable "vnet" {
  type = object({
    name          = string
    address_space = list(string)
  })
}

variable "nsg" {
  type = map(object({
    name     = string
    rules = map(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
    }))
  }))
}

variable "subnets" {
  type = map(object({
      nsg_name                                        = string
      name                                            = string
      address_space                                   = list(string)
      private_endpoint_network_policies_enabled       = bool
      private_link_service_network_policies_enabled   = bool
      service_endpoints                               = list(string)
  }))
}

variable "dns" {
  type = map(string)
}

variable "workspaceName" {
    type = string
}

variable "appInsightName" {
    type = string
}

variable "keyVault" {
  type = object({
    name        = string
    subnet-key  = string
    dns-key     = string
  })
}

variable "containerAppEnvironment" {
  type = object({
    name                    = string
    subnet-key              = string
    private-link-subnet-key = string
  })
}

variable "frontDoor" {
  type = object({
    name               = string
    custom-domain-name = string
  })
}