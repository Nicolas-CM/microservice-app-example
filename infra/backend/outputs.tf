output "storage_account_name" {
  value = azurerm_storage_account.state.name
}

output "container_name" {
  value = azurerm_storage_container.state.name
}

output "resource_group_name" {
  value = azurerm_resource_group.state.name
}

output "storage_account_key" {
  value     = azurerm_storage_account.state.primary_access_key
  sensitive = true
}