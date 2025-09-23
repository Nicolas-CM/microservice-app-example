terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

resource "azurerm_resource_group" "state" {
  name     = "terraform-state-rg"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Terraform State"
  }
}

resource "azurerm_storage_account" "state" {
  name                     = "tfstate${var.project_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Terraform State"
  }
}

resource "azurerm_storage_container" "state" {
  name                  = "terraform-state"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}