variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resourceGroupName" {
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
    subnet-id = string
    dns-id = string
  })
}