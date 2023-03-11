variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "sql-db" {
  type = object({
    name = string
    server-name = string
    subnet-id = string
    dns-id = string
    workspace-id = string
    admin = object({
      username = string
      password = string
    })
  })
}