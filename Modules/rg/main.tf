provider "azurerm" {
  features {}

  subscription_id = var.az_subscription_id
  client_id       = var.az_client_id
  client_secret   = var.az_secret
  tenant_id       = var.az_tenant
}

#Create Resource Group
resource "azurerm_resource_group" "rgm" {
  name     = "rg-tc-${var.system}"
  location = var.location
  tags = {
    DeployedBy = var.default_tag
  }
}