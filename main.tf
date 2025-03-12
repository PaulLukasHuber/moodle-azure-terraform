# =================================================================
# MAIN TERRAFORM CONFIGURATION FILE
# =================================================================
# This file serves as the entry point for the Terraform deployment,
# configuring the Azure provider and orchestrating all modules.
# =================================================================

# Configure the Azure provider with version constraints
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"  # Official Azure provider
      version = "~> 3.0"             # Compatible with 3.x versions
    }
  }
  required_version = ">= 1.0"  # Requires Terraform 1.0 or higher
}

# Initialize the Azure provider with default features
provider "azurerm" {
  features {}  # Required block even if empty
}

# =================================================================
# RESOURCE GROUP
# =================================================================
# Create a central resource group to contain all Azure resources
resource "azurerm_resource_group" "moodle_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags  # Apply common tags for resource tracking
}

# =================================================================
# NETWORKING MODULE
# =================================================================
# Deploy the virtual network, subnets, and network security groups
module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.moodle_rg.name
  location            = azurerm_resource_group.moodle_rg.location
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  tags                = var.tags
}

# =================================================================
# STORAGE MODULE
# =================================================================
# Deploy storage resources for Moodle data and files
module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.moodle_rg.name
  location            = azurerm_resource_group.moodle_rg.location
  storage_account_name = var.storage_account_name
  tags                = var.tags
}

# =================================================================
# COMPUTE MODULE
# =================================================================
# Deploy the VM that will host Moodle first, so we can get its
# public IP for the database firewall rules
module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.moodle_rg.name
  location            = azurerm_resource_group.moodle_rg.location
  vm_name             = var.vm_name
  vm_size             = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  subnet_id           = module.networking.subnet_ids[0]  # Web tier subnet
  storage_account_name = module.storage.storage_account_name
  storage_account_key  = module.storage.storage_account_key
  db_server_fqdn      = var.db_server_name  # Will update later via null_resource
  db_name             = var.db_name
  db_admin_username   = var.db_admin_username
  db_admin_password   = var.db_admin_password
  moodle_admin_email  = var.moodle_admin_email
  moodle_admin_user   = var.moodle_admin_user
  moodle_admin_password = var.moodle_admin_password
  moodle_site_name    = var.moodle_site_name
  tags                = var.tags
}

# =================================================================
# DATABASE MODULE
# =================================================================
# Now deploy the database, allowing access from the VM's public IP
module "database" {
  source                  = "./modules/database"
  resource_group_name     = azurerm_resource_group.moodle_rg.name
  location                = azurerm_resource_group.moodle_rg.location
  db_server_name          = var.db_server_name
  db_name                 = var.db_name
  db_admin_username       = var.db_admin_username
  db_admin_password       = var.db_admin_password
  subnet_id               = module.networking.subnet_ids[1]  # Database subnet
  private_endpoint_subnet_id = module.networking.subnet_ids[2]  # Private endpoint subnet
  vm_name                 = var.vm_name
  vm_depends_on           = [module.compute.vm_id]  # Create dependency on the VM
  tags                    = var.tags
}

# =================================================================
# SECURITY MODULE
# =================================================================
# Deploy monitoring and security resources
module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.moodle_rg.name
  location            = azurerm_resource_group.moodle_rg.location
  vm_id               = module.compute.vm_id
  subnet_ids          = module.networking.subnet_ids
  tags                = var.tags
}