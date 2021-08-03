variable "web_address_prefix" {
  type        = string
  description = "Address prefix"
  default     = "10.0.100.0/24"
}

variable "vm_count" {
  type        = number
  description = "Count of Vms to build"
}

variable "default_tag" {
  type        = string
  description = "Default tags"
  default     = "DeployedBy: Terraform"
}

variable "aset_id" {
  type        = string
  description = "Availability Set ID"
}
variable "location" {
  type        = string
  description = "Azure datacenter location"
}

variable "vnet_name" {
  type        = string
  description = "VNet name"
}

variable "resource_group_name" {
  type        = string
  description = "RG"
}

variable "webserver_name" {
  type        = string
  description = "Web server name"
  default     = "webserver"
}

variable "os" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}



variable "managed_disk_type" {
  type        = string
  description = "Managed disk type"
  default     = "Standard_LRS"
}

variable "admin_username" {
  type        = string
  description = "Admin username"
}

variable "admin_password" {
  type        = string
  description = "Admin password"
}