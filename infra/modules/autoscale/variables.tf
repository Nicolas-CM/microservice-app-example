variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "target_resource_id" {
  type        = string
  description = "ID of the App Service Plan to autoscale"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "service_name" {
  type        = string
  description = "Name of the service being scaled"
}

variable "min_capacity" {
  type        = number
  description = "Minimum number of instances"
  default     = 1
}

variable "max_capacity" {
  type        = number
  description = "Maximum number of instances"
  default     = 5
}

variable "cpu_threshold_increase" {
  type        = number
  description = "CPU threshold for scaling up"
  default     = 70
}

variable "cpu_threshold_decrease" {
  type        = number
  description = "CPU threshold for scaling down"
  default     = 30
}

variable "memory_threshold_increase" {
  type        = number
  description = "Memory threshold for scaling up"
  default     = 80
}