#Create Web Subnet
resource "azurerm_subnet" "subnet_web" {
  name                 = "snet-web-${var.location}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.web_address_prefix]
}

#Create NIC (Webserver)
resource "azurerm_network_interface" "nic_ws" {
  count               = var.vm_count
  name                = "${var.webserver_name}-${count.index}.nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = {
    DeployedBy = var.default_tag
  }

  ip_configuration {
    name                          = "Default"
    subnet_id                     = azurerm_subnet.subnet_web.id
    private_ip_address_allocation = "dynamic"
  }
}

#Create VM (Webserver)
resource "azurerm_virtual_machine" "vm-ws" {
  count                 = var.vm_count
  name                  = "${var.webserver_name}-${count.index}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [element(azurerm_network_interface.nic_ws.*.id, count.index)]
  vm_size               = "Standard_B2ms"
  availability_set_id   = var.aset_id
  tags = {
    DeployedBy = var.default_tag
  }

  storage_os_disk {
    name              = "${var.webserver_name}-${count.index}-os"
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
    computer_name  = var.webserver_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

#Create VM Extension
resource "azurerm_virtual_machine_extension" "ws_ext" {
  count                = var.vm_count
  name                 = "${var.webserver_name}-${count.index}"
  virtual_machine_id   = element(azurerm_virtual_machine.vm-ws.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
      "script": "${filebase64("./modules/vm/nginxconfig.sh")}"
  }
  SETTINGS
}

