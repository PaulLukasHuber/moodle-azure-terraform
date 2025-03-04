# Output the public IP address to access the Moodle instance
output "moodle_url" {
  description = "URL to access the Moodle site"
  value       = "http://${module.compute.public_ip_address}"
}

# Output the FQDN for the Moodle VM
output "moodle_fqdn" {
  description = "FQDN for the Moodle VM"
  value       = module.compute.public_ip_fqdn
}

# Output the PostgreSQL server FQDN
output "postgresql_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.database.db_server_fqdn
}

# Output the storage account name
output "storage_account_name" {
  description = "Name of the storage account used for Moodle files"
  value       = module.storage.storage_account_name
}

# Output the resource group name
output "resource_group_name" {
  description = "Name of the resource group containing all resources"
  value       = azurerm_resource_group.moodle_rg.name
}

# Output connection instructions
output "connection_instructions" {
  description = "Instructions to connect to the Moodle VM"
  value       = "Connect via SSH: ssh ${var.vm_admin_username}@${module.compute.public_ip_address}"
}

# Output Moodle admin login URL
output "moodle_admin_url" {
  description = "URL to access the Moodle admin panel"
  value       = "http://${module.compute.public_ip_address}/admin"
}