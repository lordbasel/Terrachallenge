#Create Keyvault
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "kv" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true
  enabled_for_deployment          = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  sku_name                        = "standard"
}

resource "azurerm_key_vault_access_policy" "kv_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.client_id

  key_permissions = [
    "get", "list",
  ]
  secret_permissions = [
    "get", "backup", "delete", "list", "purge", "recover", "restore", "set",
  ]
  storage_permissions = [
    "get",
  ]
  certificate_permissions = [
    "get",
  ]
}

#Create Web VM password
resource "random_password" "web_password" {
  length = 16
  upper  = true
  lower  = true
  number = true
}

#Create Web KV Secret
resource "azurerm_key_vault_secret" "web_password" {
  name         = "${var.webservername}-password"
  value        = random_password.web_password.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

#Create JB VM password
resource "random_password" "jb_password" {
  length = 16
  upper  = true
  lower  = true
  number = true
}

#Create JB KV Secret
resource "azurerm_key_vault_secret" "jb_password" {
  name         = "${var.jumpboxservername}-password"
  value        = random_password.jb_password.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}