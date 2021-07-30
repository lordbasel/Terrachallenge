#Provider Info
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.69.0"
    }
  }
}
provider "azurerm" {
  features {}

  subscription_id = var.az_subscription_id
  client_id       = var.az_client_id
  client_secret   = var.az_secret
  tenant_id       = var.az_tenant
}

#Call RG Module
module "rg" {
  source   = "./modules/rg"
  location = var.location
  name     = var.resource_group_name
}

#Call Bastion Module
module "bastion" {
  source              = "./modules/bastion"
  location            = module.rg.rg_location
  bastionhost_name    = var.bastionhost_name
  bastion_subnet      = azurerm_subnet.subnet_bastion.id
  resource_group_name = module.rg.rg_name
}

#Create VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-tc-${var.location}"
  address_space       = var.vnet_address_space
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
  tags = {
    DeployedBy = var.default_tag
  }
}

#Create Web Subnet
resource "azurerm_subnet" "subnet_web" {
  name                 = "snet-web-${var.location}"
  resource_group_name  = module.rg.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.web_address_prefix]
}

#Create Jumpbox Subnet
resource "azurerm_subnet" "subnet_jb" {
  name                 = "snet-jb-${var.location}"
  resource_group_name  = module.rg.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.jb_address_prefix]
}

#Create Bastion Subnet
resource "azurerm_subnet" "subnet_bastion" {
  name                 = "snet-bastion-${var.location}"
  resource_group_name  = module.rg.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_address_prefix]
}

#Create Public IP (Webserver)
resource "azurerm_public_ip" "publicip" {
  name                = "pip-tc-${var.webservername}-${var.location}"
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
  allocation_method   = "Static"
  tags = {
    DeployedBy = var.default_tag
  }
}

#Create NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-http-${var.system}"
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
  tags = {
    DeployedBy = var.default_tag
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Associate NSG
resource "azurerm_subnet_network_security_group_association" "nsgasc" {
  subnet_id                 = azurerm_subnet.subnet_web.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#Create NIC (Webserver)
resource "azurerm_network_interface" "nic_ws" {
  name                = "nic-tc-${var.webservername}"
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
  tags = {
    DeployedBy = var.default_tag
  }

  ip_configuration {
    name                          = "nic-cfg-${var.webservername}"
    subnet_id                     = azurerm_subnet.subnet_web.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

#Create NIC (Jumpbox)
resource "azurerm_network_interface" "nic_jb" {
  name                = "nic-tc-${var.jumpboxservername}"
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
  tags = {
    DeployedBy = var.default_tag
  }

  ip_configuration {
    name                          = "nic-cfg-${var.jumpboxservername}"
    subnet_id                     = azurerm_subnet.subnet_jb.id
    private_ip_address_allocation = "dynamic"
  }
}

#Create VM (Webserver)
resource "azurerm_virtual_machine" "vm-ws" {
  name                  = var.webservername
  location              = module.rg.rg_location
  resource_group_name   = module.rg.rg_name
  network_interface_ids = [azurerm_network_interface.nic_ws.id]
  vm_size               = "Standard_B2ms"
  tags = {
    DeployedBy = var.default_tag
  }

  storage_os_disk {
    name              = "dsk-tc-${var.webservername}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.managed_disk_type
    disk_size_gb      = "128"
  }

  storage_image_reference {
    publisher = var.os.publisher
    offer     = var.os.offer
    sku       = var.os.sku
    version   = var.os.version
  }

  os_profile {
    computer_name  = var.webservername
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt install nginx -y",
      "sudo systemctl start nginx",
      "exit"
    ]
    connection {
      type     = "ssh"
      host     = azurerm_public_ip.publicip.ip_address
      user     = var.admin_username
      password = var.admin_password
    }
  }
}

#Create VM (Jumpbox)
resource "azurerm_virtual_machine" "vm-jb" {
  name                  = var.jumpboxservername
  location              = module.rg.rg_location
  resource_group_name   = module.rg.rg_name
  network_interface_ids = [azurerm_network_interface.nic_jb.id]
  vm_size               = "Standard_B2ms"
  tags = {
    DeployedBy = var.default_tag
  }

  storage_os_disk {
    name              = "dsk-tc-${var.jumpboxservername}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.managed_disk_type
  }

  storage_image_reference {
    publisher = var.os.publisher
    offer     = var.os.offer
    sku       = var.os.sku
    version   = var.os.version
  }

  os_profile {
    computer_name  = var.jumpboxservername
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}