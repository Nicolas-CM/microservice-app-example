terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  # Backend configuration is provided via terraform init in the CI/CD pipeline
  # Example of expected values:
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"      # Provided by RESOURCE_GROUP env var
  #   storage_account_name = "tfstatemicroservicedev"  # Provided by STORAGE_ACCOUNT_NAME secret
  #   container_name      = "tfstate"                  # Fixed value in workflow
  #   key                = "terraform.tfstate"         # Fixed value in workflow
  # }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}