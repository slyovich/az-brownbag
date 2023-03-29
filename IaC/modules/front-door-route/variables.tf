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

variable "private-link-id" {
  type = string
}

variable "origin-name" {
  type = string
}

variable "origin-host" {
  type = string
}