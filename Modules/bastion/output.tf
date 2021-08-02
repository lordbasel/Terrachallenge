output "bastion_pip" {
 value = azurerm_public_ip.pip_bh.ip_address
 description = "Bastion Host PIP"
}