resource "azurerm_storage_account" "moodle_storage" {
  name                     = lower(replace("${var.project_name}${var.environment}sa", "-", ""))
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  
  # Security settings
  min_tls_version          = "TLS1_2"


  # Allow blob public access for Moodle content files
  allow_nested_items_to_be_public = true
  
  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT"]
      allowed_origins    = ["*"] # In production, restrict to your domain
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

# Container for Moodle data files
resource "azurerm_storage_container" "moodle_data" {
  name                  = "moodledata"
  storage_account_name  = azurerm_storage_account.moodle_storage.name
  container_access_type = "private"
}

# Container for Moodle backups
resource "azurerm_storage_container" "moodle_backups" {
  name                  = "moodlebackups"
  storage_account_name  = azurerm_storage_account.moodle_storage.name
  container_access_type = "private"
}

# Container for public content (like course images)
resource "azurerm_storage_container" "moodle_public" {
  name                  = "moodlepublic"
  storage_account_name  = azurerm_storage_account.moodle_storage.name
  container_access_type = "blob" # Public read access for blobs
}