variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "storage" {
  type = object({
    name = string
    replication_type = string
    access_tier = string
    public_access = bool
    is_hns = bool
  })
}

variable "private-endpoint" {
  type = object({
    subnet-id = string
    dns-id = string
    subresource = string
  })
  default = null
}

variable "queues" {
  type = map(string)
}

variable "role-assignments" {
  type = list(object({
    principal-id = string
    role = string
  }))
  default = null
}