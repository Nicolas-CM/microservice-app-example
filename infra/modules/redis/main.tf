resource "azurerm_redis_cache" "redis" {
  name                 = var.redis_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  capacity             = var.capacity
  family               = var.family
  sku_name             = var.sku_name
  non_ssl_port_enabled = true
  minimum_tls_version  = "1.2"

  redis_configuration {
    maxmemory_reserved = var.maxmemory_reserved
    maxmemory_delta    = var.maxmemory_delta
    maxmemory_policy   = "allkeys-lru"
  }

  tags = {
    Environment = var.environment
    Project     = "microservices-example"
  }
}