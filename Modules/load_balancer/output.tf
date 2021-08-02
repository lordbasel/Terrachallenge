output "lb_pip" {
  value       = azurerm_public_ip.lb_pip.ip_address
  description = "Load Balancer PIP"
}