resource "azurerm_availability_set" "aset" {
  name                         = "${var.webserver_name}-aset"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_update_domain_count = 2
  platform_fault_domain_count  = 2
  managed                      = true
}