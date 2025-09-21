output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "acr_login_server" {
  description = "The login server URL for Azure Container Registry"
  value       = module.acr.login_server
}

output "redis_host" {
  description = "The hostname of the Redis instance"
  value       = module.redis.redis_host
  sensitive   = true
}

output "frontend_url" {
  description = "The URL of the frontend application"
  value       = "https://${module.frontend.app_url}"
}

output "auth_api_url" {
  description = "The URL of the auth API"
  value       = "https://${module.auth_api.app_url}"
}

output "users_api_url" {
  description = "The URL of the users API"
  value       = "https://${module.users_api.app_url}"
}

output "todos_api_url" {
  description = "The URL of the todos API"
  value       = "https://${module.todos_api.app_url}"
}

output "log_processor_url" {
  description = "The URL of the log processor"
  value       = "https://${module.log_processor.app_url}"
}