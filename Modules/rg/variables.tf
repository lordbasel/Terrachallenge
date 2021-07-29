variable "system" {
  type        = string
  description = "Name of the environment"
  default     = "Terraform"
}

variable "location" {
  type        = string
  description = "Azure datacenter location"
  default     = "eastus"
}

variable "default_tag" {
  type        = string
  description = "Default tags"
  default     = "DeployedBy: Terraform"
}

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