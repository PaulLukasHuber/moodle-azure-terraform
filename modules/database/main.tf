# =================================================================
# DATABASE MODULE - MAIN CONFIGURATION
# =================================================================
# This module creates and configures the PostgreSQL database
# that Moodle will use to store its data
# =================================================================

# Create PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "moodle_db_server" {
  name                = var.db_server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Burstable SKU suitable for development/testing environments
  # Choose a higher tier for production workloads
  sku_name            = "B_Standard_B1ms"
  
  storage_mb          = 32768        # 32 GB storage
  backup_retention_days = 7          # Keep backups for 7 days
  geo_redundant_backup_enabled = false # Disabled to reduce costs
  auto_grow_enabled    = true        # Allow storage to grow as needed

  # Database admin credentials
  administrator_login          = var.db_admin_username
  administrator_password       = var.db_admin_password
  version                      = "13"  # PostgreSQL version 13

  tags = var.tags
}

# Create PostgreSQL database for Moodle
resource "azurerm_postgresql_flexible_server_database" "moodle_db" {
  name      = var.db_name
  server_id = azurerm_postgresql_flexible_server.moodle_db_server.id
  charset   = "UTF8"       # Unicode support for international content
  collation = "en_US.utf8" # English US collation for sorting
}

# =================================================================
# FIREWALL RULES
# =================================================================

# Configure PostgreSQL firewall rule to allow Azure services
# This is needed for the VM to connect to the database
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.moodle_db_server.id
  start_ip_address = "0.0.0.0"  # Special IP that allows Azure services
  end_ip_address   = "0.0.0.0"  # When start and end are 0.0.0.0, it allows Azure services
}