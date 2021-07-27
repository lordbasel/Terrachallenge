system = "terrachallenge"
default_tag = "DeployedBy: Terraform"
webservername = "webserver01"
jumpboxservername = "jumpbox01"
location = "eastus"
admin_username = "terrachallengeadmin"
vnet_address_space = [ "10.0.100.0/16","10.1.100.0/16" ]
os  = {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
}