output "storage_account_id" {
  description = "ID of the Storage Account"
  value       = azurerm_storage_account.moodle_storage.id
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.moodle_storage.name
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the Storage Account"
  value       = azurerm_storage_account.moodle_storage.primary_access_key
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the Storage Account"
  value       = azurerm_storage_account.moodle_storage.primary_connection_string
  sensitive   = true
}

output "moodle_data_container_name" {
  description = "Name of the Moodle data container"
  value       = azurerm_storage_container.moodle_data.name
}

output "moodle_backups_container_name" {
  description = "Name of the Moodle backups container"
  value       = azurerm_storage_container.moodle_backups.name
}

output "moodle_public_container_name" {
  description = "Name of the Moodle public container"
  value       = azurerm_storage_container.moodle_public.name
}