variable "resource_group_name" {
  type        = string
  description = "RG"
}

variable "location" {
  type        = string
  description = "Azure datacenter location"
}

variable "name" {
  type        = string
  description = "Keyvault Name"
  default     = "terrachallengevault"
}

variable "webservername" {
  type        = string
  description = "Web server name"
}

variable "jumpboxservername" {
  type        = string
  description = "Jumpbox server name"
}

# variable "rg" {
#   type        = string
#   description = "Resource group object"
# }

# variable "tenant_id" {
#   type        = string
#   description = "Tenant ID"
# }

# variable "object_id" {
#   type        = string
#   description = "Object ID"
# }