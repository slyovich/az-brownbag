variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "keyvault-name" {
    type = string
}

variable "subnet-id" {
    type = string
}

variable "dns-id" {
    type = string
}

variable "dns-name" {
    type = string
}

variable "workspace-id" {
    type = string
}

variable "tenant-id" {
    type = string
}

variable "key-vault-default-officer-principal-id" {
  type = string
}