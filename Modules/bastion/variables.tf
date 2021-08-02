variable "location" {
  type        = string
  description = "Azure datacenter location"
}

variable "bastionhost_name" {
  type        = string
  description = "Bastion host name"
  default     = "Bastion"
}

variable "resource_group_name" {
  type        = string
  description = "RG"
}

variable "bastion_subnet" {
  type        = string
  description = "Bastion subnet"
}