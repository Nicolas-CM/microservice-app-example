variable "redis_name" {
  type        = string
  description = "Name of Redis instance"
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

variable "capacity" {
  type        = number
  description = "Redis capacity (0-6)"
  default     = 1
}

variable "family" {
  type        = string
  description = "Redis family (C or P)"
  default     = "C"
}

variable "sku_name" {
  type        = string
  description = "Redis SKU name"
  default     = "Basic"
}

variable "maxmemory_reserved" {
  type        = number
  description = "Redis max memory reserved"
  default     = 50
}

variable "maxmemory_delta" {
  type        = number
  description = "Redis max memory delta"
  default     = 50
}