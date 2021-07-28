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

#Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-tc-${var.system}"
  location = var.location
  tags = {
    DeployedBy = var.default_tag
  }
}

#Create VNet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-tc-${var.location}"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    DeployedBy = var.default_tag
  }
}

#Create Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "snet-tc-${var.location}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.100.0/24"
  tags = {
    DeployedBy = var.default_tag
  }
}

#Create Public IP (Webserver)
resource "azurerm_public_ip" "publicip" {
  name                = "pip-tc-${var.webservername}-${var.location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags = {
    DeployedBy = var.default_tag
  }
}

#Create NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-http-${var.system}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    DeployedBy = var.default_tag
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protcol                    = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Create NIC (Webserver)
resource "azurerm_network_interface" "nic_ws" {
  name                      = "nic-tc-${var.webservername}"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  network_security_group_id = azurerm_network_security_group.nsg.id
  tags = {
    DeployedBy = var.default_tag
  }

  ip_configuration {
    name                          = "nic-cfg-${var.webservername}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

#Create NIC (Jumpbox)
resource "azurerm_network_interface" "nic_jb" {
  name                      = "nic-tc-${var.jumpboxservername}"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  network_security_group_id = azurerm_network_security_group.nsg.id
  tags = {
    DeployedBy = var.default_tag
  }

  ip_configuration {
    name                          = "nic-cfg-${var.jumpboxservername}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

#Create VM (Webserver)
resource "azurerm_virtual_machine" "vm-ws" {
  name                  = var.webservername
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic_ws.id]
  vm_size               = "Standard_B2ms"
  tags = {
    DeployedBy = var.default_tag
  }

  storage_os_disk {
    name              = "dsk-tc-${var.webservername}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = lookup(var.managed_disk_type, var.location, "Standard_LRS")
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

  provisioner "file" {
    source      = "ubuntu-init.sh"
    destination = "/tmp/ubuntu-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ubuntu-init.sh",
      "/tmp/ubuntu-init.sh args",
    ]
  }
}

#Create VM (Jumpbox)
resource "azurerm_virtual_machine" "vm-jb" {
  name                  = var.jumpboxservername
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic_jb.id]
  vm_size               = "Standard_B2ms"
  tags = {
    DeployedBy = var.default_tag
  }

  storage_os_disk {
    name              = "dsk-tc-${var.jumpboxservername}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = lookup(var.managed_disk_type, var.location, "Standard_LRS")
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

output "webserver_pip" {
  value = azurerm_public_ip.publicip
}