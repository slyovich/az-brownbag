variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resourceGroupId" {
  type = string
}

variable "resourceGroupName" {
  type = string
}

variable "environment-name" {
  type = string
}

variable "app-insights-connection-string" {
  type = string
}

variable "log-analytics-workspace-id" {
  type = string
}

variable "log-analytics-workspace-key" {
  type = string
}

variable "vnet-id" {
  type = string
}

variable "subnet-id" {
  type = string
}