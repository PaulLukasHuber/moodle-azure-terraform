output "mysql_server_id" {
  description = "ID of the MySQL server"
  value       = azurerm_mysql_flexible_server.moodle_mysql.id
}

output "mysql_server_fqdn" {
  description = "FQDN of the MySQL server"
  value       = azurerm_mysql_flexible_server.moodle_mysql.fqdn
}

output "mysql_database_name" {
  description = "Name of the Moodle database"
  value       = azurerm_mysql_flexible_database.moodle_db.name
}

output "mysql_connection_string" {
  description = "MySQL connection string"
  value       = "mysql://${azurerm_mysql_flexible_server.moodle_mysql.administrator_login}:${var.mysql_admin_password}@${azurerm_mysql_flexible_server.moodle_mysql.fqdn}:3306/${azurerm_mysql_flexible_database.moodle_db.name}"
  sensitive   = true
}