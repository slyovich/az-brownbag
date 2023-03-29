variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "front-door-name" {
  type = string
}

variable "custom-domain-name" {
  type = string
  default = null
}

variable "endpoint-name" {
  type = string
}

variable "private-link-id" {
  type = string
}

variable "private-link-ip-address" {
  type = string
}