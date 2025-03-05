# Create PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "moodle_db_server" {
  name                = var.db_server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name            = "B_Standard_B1ms"  # Flexible Server SKU
  storage_mb          = 32768        
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled    = true

  administrator_login          = var.db_admin_username
  administrator_password       = var.db_admin_password
  version                      = "13"

  tags = var.tags
}

# Create PostgreSQL database
resource "azurerm_postgresql_flexible_server_database" "moodle_db" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.moodle_db_server.id
  charset   = "UTF8"
  collation = "en_US.utf8"  # Fix this value
}



# Configure PostgreSQL firewall rule to allow Azure services
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name       = "allow-azure-services"
  server_id  = azurerm_postgresql_flexible_server.moodle_db_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
