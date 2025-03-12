# =================================================================
# OUTPUTS CONFIGURATION
# =================================================================
# This file defines the values that will be displayed after successful
# deployment, providing important information about the Moodle instance
# =================================================================

# URL to access the Moodle website
output "moodle_url" {
  description = "URL to access the Moodle site"
  value       = "http://${module.compute.public_ip_address}"
  # Uses the VM's public IP to access Moodle via HTTP
}

# FQDN (Fully Qualified Domain Name) of the Moodle VM
output "moodle_fqdn" {
  description = "FQDN for the Moodle VM"
  value       = module.compute.public_ip_fqdn
  # The DNS name assigned to the public IP address
}

# PostgreSQL server FQDN for database connections
output "postgresql_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.database.db_server_fqdn
  # The hostname to use when connecting to the database
}

# Storage account name for reference
output "storage_account_name" {
  description = "Name of the storage account used for Moodle files"
  value       = module.storage.storage_account_name
  # The storage account where Moodle data is stored
}

# The resource group containing all resources
output "resource_group_name" {
  description = "Name of the resource group containing all resources"
  value       = azurerm_resource_group.moodle_rg.name
  # Useful for finding all related resources in the Azure portal
}

# SSH connection instructions
output "connection_instructions" {
  description = "Instructions to connect to the Moodle VM"
  value       = "Connect via SSH: ssh ${var.vm_admin_username}@${module.compute.public_ip_address}"
  # Command to connect to the VM using SSH
}

# Moodle admin interface URL
output "moodle_admin_url" {
  description = "URL to access the Moodle admin panel"
  value       = "http://${module.compute.public_ip_address}/admin"
  # URL to access the Moodle administration interface
}