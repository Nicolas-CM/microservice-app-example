variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Azure Client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West US"
}

variable "jwt_secret" {
  description = "Secret key for JWT token generation/validation"
  type        = string
  sensitive   = true
}

# Redis variables (if needed to override defaults)
variable "redis_capacity" {
  description = "Redis cache capacity"
  type        = number
  default     = 1
}

variable "redis_family" {
  description = "Redis cache family"
  type        = string
  default     = "C"
}

variable "redis_sku" {
  description = "Redis cache SKU"
  type        = string
  default     = "Basic"
}

# App Service variables (if needed to override defaults)
variable "app_service_sku" {
  description = "SKU for App Services"
  type        = string
  default     = "B1"
}

# Container versions
variable "frontend_version" {
  description = "Version of the frontend container"
  type        = string
  default     = "v1.0.0"
}

variable "auth_api_version" {
  description = "Version of the auth-api container"
  type        = string
  default     = "v1.0.0"
}

variable "users_api_version" {
  description = "Version of the users-api container"
  type        = string
  default     = "v1.0.0"
}

variable "todos_api_version" {
  description = "Version of the todos-api container"
  type        = string
  default     = "v1.0.0"
}

variable "log_processor_version" {
  description = "Version of the log-processor container"
  type        = string
  default     = "v1.0.0"
}