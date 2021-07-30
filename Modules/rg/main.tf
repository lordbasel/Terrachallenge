#Create Resource Group
resource "azurerm_resource_group" "rgm" {
  name     = var.name
  location = var.location
  tags = {
    DeployedBy = var.default_tag
  }
}