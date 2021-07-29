system                = "terrachallenge"
default_tag           = "Terraform"
webservername         = "webserver01"
jumpboxservername     = "jumpbox01"
location              = "eastus"
vnet_address_space    = ["10.0.0.0/16", "10.1.0.0/16"]
web_address_prefix    = "10.0.100.0/24"
jb_address_prefix     = "10.0.110.0/24"
bastion_address_prefix = "10.0.120.0/24"
managed_disk_type     = "Standard_LRS"
os = {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
  version   = "latest"
}