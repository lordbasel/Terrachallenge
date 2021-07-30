#Create Bastion PIP
resource "azurerm_public_ip" "pip_bh" {
  name                = "${var.bastionhost_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Create Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = var.bastionhost_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "default"
    subnet_id            = var.bastion_subnet
    public_ip_address_id = azurerm_public_ip.pip_bh.id
  }
}