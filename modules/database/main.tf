resource "azurerm_mysql_flexible_server" "moodle_mysql" {
  name                = var.mysql_server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.mysql_admin_username
  administrator_password       = var.mysql_admin_password

  # Updated to valid SKU name for flexible server
  sku_name                     = "B_Standard_B1s"
  
  storage {
    # Minimum size is 20GB for MySQL Flexible Server
    size_gb = 20
    auto_grow_enabled = true
  }
  
  # Must use exact version
  version                      = "8.0.21"

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  
  # Configure high availability if needed (commented out to reduce costs)
  # high_availability {
  #   mode = "ZoneRedundant"
  # }

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

# Create Moodle database
resource "azurerm_mysql_flexible_database" "moodle_db" {
  name                = "moodledb"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.moodle_mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# Configure firewall rule to allow access from Azure services
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.moodle_mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Configure private network access
resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "mysql-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = true
}