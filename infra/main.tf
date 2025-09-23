resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location
}

module "acr" {
  source = "./modules/acr"

  acr_name            = "microserviceappdevacr" # Nombre fijo sin variables para evitar guiones
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
}

module "redis" {
  source = "./modules/redis"

  redis_name          = "${var.project_name}-${var.environment}-redis"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  maxmemory_reserved  = 50
  maxmemory_delta     = 50
}

# Frontend App Service
module "frontend" {
  source = "./modules/app_service"

  app_name            = "${var.project_name}-${var.environment}-frontend"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  sku_name            = "B1"

  acr_login_server   = module.acr.login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password
  docker_image       = "frontend"
  docker_image_tag   = var.frontend_version

  app_settings = {
    "AUTH_API_URL"  = "https://${module.auth_api.app_url}"
    "TODOS_API_URL" = "https://${module.todos_api.app_url}"
  }
}

# Auth API App Service
module "auth_api" {
  source = "./modules/app_service"

  app_name            = "${var.project_name}-${var.environment}-auth-api"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  sku_name            = "B1"

  acr_login_server   = module.acr.login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password
  docker_image       = "auth-api"
  docker_image_tag   = var.auth_api_version

  app_settings = {
    "AUTH_API_PORT"     = "8081"
    "USERS_API_ADDRESS" = "https://${module.users_api.app_url}"
    "JWT_SECRET"        = var.jwt_secret
  }
}

# Users API App Service
module "users_api" {
  source = "./modules/app_service"

  app_name            = "${var.project_name}-${var.environment}-users-api"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  sku_name            = "B1"

  acr_login_server   = module.acr.login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password
  docker_image       = "users-api"
  docker_image_tag   = var.users_api_version

  app_settings = {
    "SERVER_PORT" = "8083"
    "JWT_SECRET"  = var.jwt_secret
  }
}

# Todos API App Service
module "todos_api" {
  source = "./modules/app_service"

  app_name            = "${var.project_name}-${var.environment}-todos-api"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  sku_name            = "B1"

  acr_login_server   = module.acr.login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password
  docker_image       = "todos-api"
  docker_image_tag   = var.todos_api_version

  app_settings = {
    "TODO_API_PORT"  = "8082"
    "JWT_SECRET"     = var.jwt_secret
    "REDIS_HOST"     = module.redis.redis_host
    "REDIS_PORT"     = module.redis.redis_port
    "REDIS_PASSWORD" = module.redis.redis_password
    "REDIS_CHANNEL"  = "log_channel"
  }
}

# Log Processor App Service
module "log_processor" {
  source = "./modules/app_service"

  app_name            = "${var.project_name}-${var.environment}-log-processor"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
  sku_name            = "B1"

  acr_login_server   = module.acr.login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password
  docker_image       = "log-message-processor"
  docker_image_tag   = var.log_processor_version

  app_settings = {
    "REDIS_HOST"     = module.redis.redis_host
    "REDIS_PORT"     = module.redis.redis_port
    "REDIS_PASSWORD" = module.redis.redis_password
    "REDIS_CHANNEL"  = "log_channel"
  }
}