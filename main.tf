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

#Call VM Module
module "vm" {
  source              = "./modules/vm"
  vm_count            = var.vm_count
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
  vnet_name           = azurerm_virtual_network.vnet.name
  admin_username      = var.admin_username
  admin_password      = module.keyvault.web_password
  aset_id             = module.aset.aset_id
  lb_backend          = module.load_balancer.lb_backend
  os = {
    publisher = var.os.publisher
    offer     = var.os.offer
    sku       = var.os.sku
    version   = var.os.version
  }
}

#Call ASET Module
module "aset" {
  source              = "./modules/aset"
  resource_group_name = module.rg.rg_name
  location            = module.rg.rg_location
}

#Call Bastion Module
module "bastion" {
  source              = "./modules/bastion"
  location            = module.rg.rg_location
  bastionhost_name    = var.bastionhost_name
  bastion_subnet      = azurerm_subnet.subnet_bastion.id
  resource_group_name = module.rg.rg_name
}

#Call Load Balancer Module
module "load_balancer" {
  source              = "./modules/load_balancer"
  location            = module.rg.rg_location
  lb_name             = var.lb_name
  resource_group_name = module.rg.rg_name
  #nic_id              = module.vm.nic_id
}

#Call Key Vault Module
module "keyvault" {
  source              = "./modules/keyvault"
  location            = module.rg.rg_location
  resource_group_name = module.rg.rg_name
  jumpboxservername   = var.jumpboxservername
  webservername       = var.webservername
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

#Create Jumpbox Subnet
resource "azurerm_subnet" "subnet_jb" {
  name                 = "snet-jb-${var.location}"
  resource_group_name  = module.rg.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.jb_address_prefix]
}

#Create Bastion Subnet
resource "azurerm_subnet" "subnet_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = module.rg.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_address_prefix]
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
    name                       = "HTTPIn"
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

#Associate NSG Web
resource "azurerm_subnet_network_security_group_association" "nsgasc" {
  subnet_id                 = module.vm.subnet_web
  network_security_group_id = azurerm_network_security_group.nsg.id
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
    admin_password = module.keyvault.jb_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}