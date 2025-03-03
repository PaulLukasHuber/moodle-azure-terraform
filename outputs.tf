output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.moodle_rg.name
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = module.networking.vnet_id
}

output "mysql_server_fqdn" {
  description = "FQDN of the MySQL server"
  value       = module.database.mysql_server_fqdn
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = module.storage.storage_account_name
}

output "moodle_url" {
  description = "URL of the Moodle application"
  value       = "https://${module.webapp.web_app_default_hostname}"
}

output "moodle_outbound_ips" {
  description = "Outbound IP addresses of the Moodle Web App"
  value       = module.webapp.web_app_outbound_ip_addresses
}

# Add sensitive information that might be needed for manual configurations
output "sensitive_info" {
  description = "Sensitive information (Database credentials, Storage keys)"
  value = {
    mysql_admin_username = var.mysql_admin_username
    mysql_admin_password = var.mysql_admin_password
    moodle_admin_user    = var.moodle_admin_user
    moodle_admin_password = var.moodle_admin_password
    storage_account_key  = module.storage.storage_account_primary_access_key
  }
  sensitive = true
}