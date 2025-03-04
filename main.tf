# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "moodle_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Deploy networking resources
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

# Deploy storage resources
module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.moodle_rg.name
  location            = azurerm_resource_group.moodle_rg.location
  storage_account_name = var.storage_account_name
  tags                = var.tags
}

# Deploy compute resources first, so we can get the VM's public IP for the database firewall rule
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
  db_server_fqdn      = var.db_server_name  # We'll update this later via a null_resource
  db_name             = var.db_name
  db_admin_username   = var.db_admin_username
  db_admin_password   = var.db_admin_password
  moodle_admin_email  = var.moodle_admin_email
  moodle_admin_user   = var.moodle_admin_user
  moodle_admin_password = var.moodle_admin_password
  moodle_site_name    = var.moodle_site_name
  tags                = var.tags
}

# Now deploy database resources, allowing access from the VM's public IP
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

# Deploy security resources
module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.moodle_rg.name
  location            = azurerm_resource_group.moodle_rg.location
  vm_id               = module.compute.vm_id
  subnet_ids          = module.networking.subnet_ids
  tags                = var.tags
}

# Update the Moodle configuration to use the actual database FQDN after it's created
resource "null_resource" "update_moodle_config" {
  # This will run a script on the VM to update the Moodle config with the actual database FQDN
  depends_on = [module.compute, module.database]

  # This triggers the resource to run when the database FQDN changes
  triggers = {
    db_server_fqdn = module.database.db_server_fqdn
  }

  # Use Azure CLI to run a command on the VM
  provisioner "local-exec" {
    command = <<-EOT
      az vm run-command invoke \
        --resource-group ${azurerm_resource_group.moodle_rg.name} \
        --name ${var.vm_name} \
        --command-id RunShellScript \
        --scripts 'sed -i "s|dbhost.*|dbhost    = \"${module.database.db_server_fqdn}\";|g" /var/www/html/moodle/config.php'
    EOT
  }
}