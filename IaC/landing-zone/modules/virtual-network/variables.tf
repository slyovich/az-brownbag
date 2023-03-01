variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
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
  }))
}

variable "dns" {
  type = map(object({
    name     = string
  }))
}