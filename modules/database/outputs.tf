output "db_server_id" {
  description = "ID of the PostgreSQL server"
  value       = azurerm_postgresql_server.moodle_db.id
}

output "db_server_name" {
  description = "Name of the PostgreSQL server"
  value       = azurerm_postgresql_server.moodle_db.name
}

output "db_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_server.moodle_db.fqdn
}

output "db_name" {
  description = "Name of the Moodle database"
  value       = azurerm_postgresql_database.moodle_db.name
}

output "db_connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgres://${var.db_admin_username}@${azurerm_postgresql_server.moodle_db.name}:${var.db_admin_password}@${azurerm_postgresql_server.moodle_db.fqdn}:5432/${azurerm_postgresql_database.moodle_db.name}"
  sensitive   = true
}

output "firewall_rule_azure_services" {
  description = "ID of the firewall rule for Azure services"
  value       = azurerm_postgresql_firewall_rule.allow_azure_services.id
}

# Remove or comment out this output
# output "firewall_rule_vm_ip" {
#   description = "ID of the firewall rule for the VM's public IP"
#   value       = azurerm_postgresql_firewall_rule.allow_vm_ip.id
# }