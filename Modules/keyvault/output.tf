output "web_password" {
  value = azurerm_key_vault_secret.web_password.value
}

output "jb_password" {
  value = azurerm_key_vault_secret.jb_password.value
}