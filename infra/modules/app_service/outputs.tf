output "app_url" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "app_name" {
  value = azurerm_linux_web_app.app.name
}

output "identity_principal_id" {
  value = azurerm_linux_web_app.app.identity[0].principal_id
}