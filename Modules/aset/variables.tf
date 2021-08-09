variable "resource_group_name" {
  type        = string
  description = "RG"
}

variable "webserver_name" {
  type        = string
  description = "Web server name"
  default     = "webserver"
}

variable "location" {
  type        = string
  description = "Azure datacenter location"
}