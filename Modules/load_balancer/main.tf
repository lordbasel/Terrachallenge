#Create PIP LB
resource "azurerm_public_ip" "lb_pip" {
  name                = "${var.lb_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#Create Load Balancer
resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "Default"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

#Create LB Backend Pool
resource "azurerm_lb_backend_address_pool" "lb_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "LBBackendPool"
}

# #Create Backend Pool Association
# resource "azurerm_network_interface_backend_address_pool_association" "lb_pool_assoc" {
#   network_interface_id    = var.nic_id
#   ip_configuration_name   = "Default"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.lb_pool.id
# }

#Create LB Rule
resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_pool.id
  frontend_ip_configuration_name = "Default"
  probe_id                       = azurerm_lb_probe.lb_probe.id
}

#Create LB Probe
resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "LBHealthProbe"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
}
