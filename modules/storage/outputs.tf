output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.moodle_storage.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.moodle_storage.name
}

output "storage_account_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.moodle_storage.primary_access_key
  sensitive   = true
}

output "blob_endpoint" {
  description = "Blob endpoint URL"
  value       = azurerm_storage_account.moodle_storage.primary_blob_endpoint
}

output "moodle_container_name" {
  description = "Name of the container for Moodle data"
  value       = azurerm_storage_container.moodle_data.name
}

output "moodle_share_name" {
  description = "Name of the file share for Moodle files"
  value       = azurerm_storage_share.moodle_share.name
}

output "moodle_share_url" {
  description = "URL of the file share for Moodle files"
  value       = "${azurerm_storage_account.moodle_storage.primary_file_endpoint}${azurerm_storage_share.moodle_share.name}"
}