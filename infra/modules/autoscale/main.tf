resource "azurerm_monitor_autoscale_setting" "app_autoscale" {
  name                = "${var.app_name}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = var.target_resource_id

  profile {
    name = "default"
    capacity {
      minimum = var.min_capacity
      maximum = var.max_capacity
      default = var.min_capacity
    }

    # CPU Scale Up
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = var.target_resource_id
        time_grain         = "PT1M"
        statistic         = "Average"
        time_window       = "PT5M"
        time_aggregation  = "Average"
        operator          = "GreaterThan"
        threshold         = var.cpu_threshold_increase
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    # CPU Scale Down
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = var.target_resource_id
        time_grain         = "PT1M"
        statistic         = "Average"
        time_window       = "PT5M"
        time_aggregation  = "Average"
        operator          = "LessThan"
        threshold         = var.cpu_threshold_decrease
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    # Memory Scale Up
    rule {
      metric_trigger {
        metric_name        = "MemoryPercentage"
        metric_resource_id = var.target_resource_id
        time_grain         = "PT1M"
        statistic         = "Average"
        time_window       = "PT5M"
        time_aggregation  = "Average"
        operator          = "GreaterThan"
        threshold         = var.memory_threshold_increase
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
    }
  }

  tags = {
    Environment = var.environment
    Service     = var.service_name
    Managed_By  = "Terraform"
  }
}