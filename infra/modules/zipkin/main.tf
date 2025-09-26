resource "azurerm_service_plan" "zipkin_plan" {
  name                = "${var.app_name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name
}

resource "azurerm_linux_web_app" "zipkin" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.zipkin_plan.id

  site_config {
    always_on = true
    application_stack {
      docker_image_name = var.zipkin_image
    }
  }

  app_settings = {
    WEBSITES_PORT = "9411"
    ZIPKIN_STORAGE_TYPE = "mem"
  DOCKER_REGISTRY_SERVER_URL      = var.acr_login_server
  DOCKER_REGISTRY_SERVER_USERNAME = var.acr_admin_username
  DOCKER_REGISTRY_SERVER_PASSWORD = var.acr_admin_password
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }

  tags = {
    environment = var.environment
  }
}