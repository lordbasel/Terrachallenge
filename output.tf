output "webserver_pip" {
  description = "Webserver1 PIP"
  value       = azurerm_public_ip.publicip.ip_address
}

output "bastion_pip" {
  value       = module.bastion.bastion_pip
  description = "Bastion Host PIP"
}

output "lb_pip" {
  description = "Load Balancer PIP"
  value       = module.load_balancer.lb_pip
}