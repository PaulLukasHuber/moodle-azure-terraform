# Create the resource group for all Moodle resources
resource "azurerm_resource_group" "moodle_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

# Create networking resources
module "networking" {
  source = "./modules/networking"

  project_name            = var.project_name
  location                = var.location
  environment             = var.environment
  resource_group_name     = azurerm_resource_group.moodle_rg.name
  vnet_address_space      = var.vnet_address_space
  web_subnet_address_prefix = var.web_subnet_address_prefix
  db_subnet_address_prefix  = var.db_subnet_address_prefix
}

# Create storage resources
module "storage" {
  source = "./modules/storage"

  project_name                    = var.project_name
  location                        = var.location
  environment                     = var.environment
  resource_group_name             = azurerm_resource_group.moodle_rg.name
  storage_account_tier            = var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type
}

# Create database resources
module "database" {
  source = "./modules/database"

  project_name          = var.project_name
  location              = var.location
  environment           = var.environment
  resource_group_name   = azurerm_resource_group.moodle_rg.name
  mysql_server_name     = var.mysql_server_name
  mysql_admin_username  = var.mysql_admin_username
  mysql_admin_password  = var.mysql_admin_password
  mysql_version         = var.mysql_version
  mysql_sku_name        = var.mysql_sku_name
  mysql_storage_mb      = var.mysql_storage_mb
  web_subnet_id         = module.networking.web_subnet_id
  virtual_network_id    = module.networking.vnet_id
}

# Create webapp resources
module "webapp" {
  source = "./modules/webapp"

  project_name            = var.project_name
  location                = var.location
  environment             = var.environment
  resource_group_name     = azurerm_resource_group.moodle_rg.name
  app_service_plan_tier   = var.app_service_plan_tier
  app_service_plan_size   = var.app_service_plan_size
  mysql_server_fqdn       = module.database.mysql_server_fqdn
  mysql_database_name     = module.database.mysql_database_name
  mysql_admin_username    = var.mysql_admin_username
  mysql_admin_password    = var.mysql_admin_password
  moodle_site_name        = var.moodle_site_name
  moodle_admin_email      = var.moodle_admin_email
  moodle_admin_user       = var.moodle_admin_user
  moodle_admin_password   = var.moodle_admin_password
  storage_account_name    = module.storage.storage_account_name
  storage_account_key     = module.storage.storage_account_primary_access_key
  moodle_data_container_name = module.storage.moodle_data_container_name
  web_subnet_id           = module.networking.web_subnet_id
}