output "nic_id" {
  #value       = { for nic in azurerm_network_interface.nic : nic.name => nic.id }
  value       = azurerm_network_interface.nic.id
  description = "Webserver NIC ID"
}

output "subnet_web" {
  value       = azurerm_subnet.subnet_web.id
  description = "Webserver Subnet ID"
}