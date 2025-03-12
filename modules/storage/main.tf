# =================================================================
# STORAGE MODULE - MAIN CONFIGURATION
# =================================================================
# This module creates storage resources for Moodle files, including
# a storage account, blob container, and file share
# =================================================================

# Create a storage account for Moodle files
resource "azurerm_storage_account" "moodle_storage" {
  name                     = var.storage_account_name  # Must be globally unique
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"                # Standard performance tier
  account_replication_type = "LRS"                     # Locally redundant storage (cost-effective)
  min_tls_version          = "TLS1_2"                  # Enhanced security with TLS 1.2
  tags                     = var.tags
  
  # Configure blob service with CORS settings
  # This allows the Moodle web application to access blob storage
  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]                       # Allow all headers
      allowed_methods    = ["GET", "HEAD", "POST", "PUT"]  # HTTP methods to allow
      allowed_origins    = ["*"]                       # In production, restrict to your domain
      exposed_headers    = ["*"]                       # Headers that can be exposed to the browser
      max_age_in_seconds = 3600                        # Cache CORS responses for 1 hour
    }
  }
}

# Create a blob container for Moodle data
# This will store user files, course materials, etc.
resource "azurerm_storage_container" "moodle_data" {
  name                  = "moodledata"                 # Container name
  storage_account_name  = azurerm_storage_account.moodle_storage.name
  container_access_type = "private"                    # Private access for security
}

# Create a file share for Moodle files
# This can be mounted on the VM for read/write access
resource "azurerm_storage_share" "moodle_share" {
  name                 = "moodlefiles"                 # Share name
  storage_account_name = azurerm_storage_account.moodle_storage.name
  quota                = 5                             # 5 GB quota (adjust as needed)
}