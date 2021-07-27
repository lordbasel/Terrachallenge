provider "azurerm" {
}

#Create Resource Group
resource "azurerm_resource_group" "rg" {
    name                    = "tcrg-${var.system}"
    location                = var.location
    tags                    = var.default_tag
}

#Create VNet
resource "azurerm_virtual_network" "vnet" {
    name                    = "tc-vnet-${var.location}"
    address_space           = var.vnet_address_space
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    tags                    = var.default_tag
}

#Create Subnet
resource "azurerm_subnet" "subnet" {
    name                    = "tc-snet-${var.location}"
    resource_group_name     = azurerm_resource_group.rg.name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefix          = "10.0.100.0/24"
    tags                    = var.default_tag
}

#Create Public IP (Webserver)
resource "azurerm_public_ip" "publicip" {
    name                    = "tc-pip-${var.webservername}-${var.location}"
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    allocation_method       = "Static"
    tags                    = var.default_tag
}

#Create NSG
resource "azurerm_network_security_group" "nsg" {
    name = "nsg-http-${var.system}"
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name

    security_rule {
        name                            = "HTTP"
        priority                        = 1001
        direction                       = "Inbound"
        access                          = "Allow"
        protcol                         = "Tcp"
        source_port_range               = "*"
        destination_port_range          = "80"
        source_address_prefix           = "*"
        destination_address_prefix      = "*"
    }
}

#Create NIC (Webserver)
resource "azurerm_network_interface" "nic_ws" {
    name                    = "tc-nic-${var.webservername}"
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    network_security_group_id = azurerm_network_security_group.nsg.id
    tags                    = var.default_tag

    ip_configuration {
      name                              = "tc-nic-cfg-${var.webservername}"
      subnet_id                         = azurerm_subnet.subnet.id
      private_ip_address_allocation     = "dynamic"
      public_ip_address_id              = azurerm_public_ip.publicip.id
    }
}

#Create NIC (Jumpbox)
resource "azurerm_network_interface" "nic_jb" {
    name                    = "tc-nic-${var.jumpboxservername}"
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    network_security_group_id = azurerm_network_security_group.nsg.id
    tags                    = var.default_tag

    ip_configuration {
      name                              = "tc-nic-cfg-${var.jumpboxservername}"
      subnet_id                         = azurerm_subnet.subnet.id
      private_ip_address_allocation     = "dynamic"
    }
}

#Create VM (Webserver)
resource "azurerm_virtual_machine" "vm" {
    name                    = var.webservername
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    network_interface_ids   = [azurerm_network_interface.nic_ws.id]
    vm_size                 = "Standard_B2ms"

    storage_os_disk {
      name                              = "tc-dsk-${var.webservername}-os"
      caching                           = "ReadWrite"
      create_option                     = "FromImage"
      managed_disk_type                 = lookup(var.managed_disk_type, var.location, "Standard_LRS")
    }

    storage_image_reference {
      publisher                         = var.os.publisher
      offer                             = var.os.offer
      sku                               = var.os.sku
      version                           = var.os.version
    }

    os_profile {
      computer_name                     = var.webservername
      admin_username                    = var.admin_username
      admin_password                    = var.admin_password
    }

    os_profile_linux_config {
      disable_password_authentication   = false
    }

#Create VM (Jumpbox)
resource "azurerm_virtual_machine" "vm" {
    name                    = var.jumpboxservername
    location                = azurerm_resource_group.rg.location
    resource_group_name     = azurerm_resource_group.rg.name
    network_interface_ids   = [azurerm_network_interface.nic_jb.id]
    vm_size                 = "Standard_B2ms"

    storage_os_disk {
      name                              = "tc-dsk-${var.jumpboxservername}-os"
      caching                           = "ReadWrite"
      create_option                     = "FromImage"
      managed_disk_type                 = lookup(var.managed_disk_type, var.location, "Standard_LRS")
    }

    storage_image_reference {
      publisher                         = var.os.publisher
      offer                             = var.os.offer
      sku                               = var.os.sku
      version                           = var.os.version
    }

    os_profile {
      computer_name                     = var.jumpboxservername
      admin_username                    = var.admin_username
      admin_password                    = var.admin_password
    }

    os_profile_linux_config {
      disable_password_authentication   = false
    }
}
}