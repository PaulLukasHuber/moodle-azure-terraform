# Create PostgreSQL server (budget-friendly sizing)
resource "azurerm_postgresql_server" "moodle_db" {
  name                = var.db_server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Budget-friendly configuration
  sku_name            = "B_Gen5_1"  # Basic tier, Gen5, 1 vCore
  storage_mb          = 5120        # 5GB storage (minimum)
  backup_retention_days = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled    = true
  
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password
  version                      = "11"
  ssl_enforcement_enabled      = true

  tags = var.tags
}

# Create PostgreSQL database
resource "azurerm_postgresql_database" "moodle_db" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.moodle_db.name
  charset             = "UTF8"
  collation           = "en_US.UTF8"
}

# Configure PostgreSQL firewall rule to allow Azure services
resource "azurerm_postgresql_firewall_rule" "allow_azure_services" {
  name                = "allow-azure-services"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.moodle_db.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}