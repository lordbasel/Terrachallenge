variable "az_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "az_client_id" {
  type        = string
  description = "Azure client ID"
}

variable "az_secret" {
  type        = string
  description = "Azure secret"
}

variable "az_tenant" {
  type        = string
  description = "Azure tenant ID"
}
variable "system" {
  type        = string
  description = "Name of the environment"
}

variable "default_tag" {
  type        = string
  description = "Default tags"
  default     = "DeployedBy: Terraform"
}

variable "webservername" {
  type        = string
  description = "Web server name"
}

variable "jumpboxservername" {
  type        = string
  description = "Jumpbox server name"
}

variable "location" {
  type        = string
  description = "Azure datacenter location"
  default     = "eastus"
}

variable "admin_username" {
  type        = string
  description = "Admin username"
}

variable "admin_password" {
  type        = string
  description = "Admin password"
}

variable "vnet_address_space" {
  type        = list(any)
  description = "Virtual network address space"
  default     = ["10.0.100.0/24"]
}

variable "web_address_prefix" {
  type        = string
  description = "Address prefix"
  default     = "10.0.100.0/24"
}

variable "jb_address_prefix" {
  type        = string
  description = "Address prefix"
  default     = "10.0.110.0/24"
}

variable "bastion_address_prefix" {
  type        = string
  description = "Address prefix"
  default     = "10.0.120.0/24"
}
variable "managed_disk_type" {
  type        = string
  description = "Managed disk type"
  default     = "Standard_LRS"
}

variable "vm_size" {
  type        = string
  description = "Size of VM"
  default     = "Standard_B2ms"
}

variable "os" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
