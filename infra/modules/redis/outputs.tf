output "redis_host" {
  value = azurerm_redis_cache.redis.hostname
}

output "redis_port" {
  value = azurerm_redis_cache.redis.port
}

output "redis_password" {
  value     = azurerm_redis_cache.redis.primary_access_key
  sensitive = true
}