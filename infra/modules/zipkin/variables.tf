variable "resource_group_name" {
  description = "Nombre del resource group para Zipkin"
  type        = string
}

variable "location" {
  description = "Ubicación de Azure para Zipkin"
  type        = string
}

variable "app_name" {
  description = "Nombre de la aplicación Zipkin"
  type        = string
}

variable "sku_name" {
  description = "SKU del App Service Plan"
  type        = string
  default     = "B1"
}

variable "environment" {
  description = "Ambiente (dev, prod, etc)"
  type        = string
  default     = "dev"
}

variable "zipkin_image" {
  description = "Nombre completo de la imagen de Zipkin en ACR (incluye tag)"
  type        = string
}