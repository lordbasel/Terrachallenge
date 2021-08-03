variable "location" {
  type        = string
  description = "Azure datacenter location"
}

variable "lb_name" {
  type        = string
  description = "Load Balancer name"
  default     = "Load_Balancer"
}

variable "resource_group_name" {
  type        = string
  description = "RG"
}

