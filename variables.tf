variable "system" {
    type        = string
    description = "Name of the environment"
}

variable "default_tag"{
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
  type          = string
  description   = "Azure datacenter location"
  default       = "eastus"
}

variable "admin_username" {
  type          = string
  description   = "Admin username"
}

variable "admin_password" {
    type        = string
    description = "Admin password"
}

variable "vnet_address_space" {
    type        = list
    description = "Virtual network address space"
    default     = ["10.0.100.0/24"]
}

variable "managed_disk_type" {
    type = string
    description = "Managed disk type"
    default = "Standard_LRS"
}

variable "vm_size" {
  type          = string
  description = "Size of VM"
  default = "Standard_B2ms"
}

variable "os" {
    type = object({
        publisher   = string
        offer       = string
        sku         = string
        version     = string
    })
}