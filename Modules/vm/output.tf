output "nic_id" {
  value       = azurerm_network_interface.nic_ws[*].id
  description = "Webserver NIC ID"
}

output "subnet_web" {
  value       = azurerm_subnet.subnet_web.id
  description = "Webserver Subnet ID"
}