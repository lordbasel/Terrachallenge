output "lb_pip" {
  value       = azurerm_public_ip.lb_pip.ip_address
  description = "Load Balancer PIP"
}

output "lb_backend" {
  value       = azurerm_lb_backend_address_pool.lb_pool.id
  description = "Load Balancer Backend Address Pool"
}