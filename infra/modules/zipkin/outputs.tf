output "zipkin_url" {
  description = "URL pública de Zipkin"
  value       = azurerm_linux_web_app.zipkin.default_hostname
}