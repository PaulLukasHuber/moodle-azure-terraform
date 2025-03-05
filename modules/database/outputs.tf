output "db_server_id" {
  value = azurerm_postgresql_flexible_server.moodle_db_server.id
}
output "db_server_name" {
  value = azurerm_postgresql_flexible_server.moodle_db_server.name
}
output "db_server_fqdn" {
  value = azurerm_postgresql_flexible_server.moodle_db_server.fqdn
}
output "db_name" {
  value = azurerm_postgresql_flexible_server_database.moodle_db.name
}
output "db_connection_string" {
  value = "postgres://${var.db_admin_username}:${var.db_admin_password}@${azurerm_postgresql_flexible_server.moodle_db_server.fqdn}:5432/${azurerm_postgresql_flexible_server_database.moodle_db.name}"
  sensitive = true
}
output "firewall_rule_azure_services" {
  value = azurerm_postgresql_flexible_server_firewall_rule.allow_azure_services.id
}

# Remove or comment out this output
# output "firewall_rule_vm_ip" {
#   description = "ID of the firewall rule for the VM's public IP"
#   value       = azurerm_postgresql_firewall_rule.allow_vm_ip.id
# }