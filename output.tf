output "webserver_pip" {
  description = "Webserver1 PIP"
  value       = azurerm_public_ip.publicip.ip_address
}

output "bastion_pip" {
 value = module.bastion.bastion_pip
 description = "Bastion Host PIP"
}

output "jumpbox_ip" {
  description = "Jumpbox1 ip address"
  value = azurerm_network_interface.nic_jb.private_ip_address
}