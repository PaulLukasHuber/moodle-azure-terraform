# Create a storage account for Moodle files
resource "azurerm_storage_account" "moodle_storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"  # Locally redundant storage is more cost-effective
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
  
  # Enable blob and file services
  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT"]
      allowed_origins    = ["*"]  # In production, restrict to your domain
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }
}

# Create a container for Moodle data
resource "azurerm_storage_container" "moodle_data" {
  name                  = "moodledata"
  storage_account_name  = azurerm_storage_account.moodle_storage.name
  container_access_type = "private"
}

# Create a file share for Moodle files
resource "azurerm_storage_share" "moodle_share" {
  name                 = "moodlefiles"
  storage_account_name = azurerm_storage_account.moodle_storage.name
  quota                = 5  # 5 GB, adjust as needed within budget
}