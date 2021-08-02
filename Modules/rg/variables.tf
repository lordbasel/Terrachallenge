variable "location" {
  type        = string
  description = "Azure datacenter location"
}

variable "name" {
  type        = string
  description = "RG Name"
}
variable "default_tag" {
  type        = string
  description = "Default tags"
  default     = "DeployedBy: Terraform"
}