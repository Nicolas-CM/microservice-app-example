variable "app_name" {
  type        = string
  description = "Name of the App Service"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "sku_name" {
  type        = string
  description = "SKU name for App Service Plan"
  default     = "B1"
}

variable "acr_login_server" {
  type        = string
  description = "ACR login server URL"
}

variable "acr_admin_username" {
  type        = string
  description = "ACR admin username"
}

variable "acr_admin_password" {
  type        = string
  description = "ACR admin password"
  sensitive   = true
}

variable "docker_image" {
  type        = string
  description = "Docker image name"
}

variable "docker_image_tag" {
  type        = string
  description = "Docker image tag"
  default     = "latest"
}

variable "app_settings" {
  type        = map(string)
  description = "Additional app settings"
  default     = {}
}