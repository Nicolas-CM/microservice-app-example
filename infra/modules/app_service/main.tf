resource "azurerm_service_plan" "plan" {
  name                = "${var.app_name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type            = "Linux"
  sku_name           = var.sku_name

  tags = {
    Environment = var.environment
    Project     = "microservices-example"
  }
}

resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      docker_image_name = "${var.acr_login_server}/${var.docker_image}:${var.docker_image_tag}"
    }
    always_on = true
  }

  app_settings = merge({
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${var.acr_login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = var.acr_admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = var.acr_admin_password
  }, var.app_settings)

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    Project     = "microservices-example"
  }
}