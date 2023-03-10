variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "keyvault" {
  type = object({
    name = string
    subnet-id = string
    dns-id = string
    workspace-id = string
    tenant-id = string
  })
}

variable "key-vault-default-officer-principal-id" {
  type = string
}