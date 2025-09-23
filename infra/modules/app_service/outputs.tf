output "app_url" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "app_name" {
  value = azurerm_linux_web_app.app.name
}

output "identity_principal_id" {
  value = azurerm_linux_web_app.app.identity[0].principal_id
}

output "app_service_plan_id" {
  value = azurerm_service_plan.plan.id
  description = "ID of the App Service Plan"
}