resource "azurerm_service_plan" "moodle_plan" {
  name                = "${var.project_name}-${var.environment}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_tier == "Basic" ? "B1" : var.app_service_plan_size

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

resource "azurerm_linux_web_app" "moodle_app" {
  name                = "${var.project_name}-${var.environment}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.moodle_plan.id
  https_only          = true

  site_config {
    application_stack {
      php_version = "7.4"
    }
    always_on        = true
    minimum_tls_version = "1.2"
    
    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    # Database connection settings
    "DB_HOST"          = var.mysql_server_fqdn
    "DB_NAME"          = var.mysql_database_name
    "DB_USER"          = var.mysql_admin_username
    "DB_PASSWORD"      = var.mysql_admin_password
    
    # Moodle settings
    "MOODLE_ADMIN_USER"     = var.moodle_admin_user
    "MOODLE_ADMIN_PASSWORD" = var.moodle_admin_password
    "MOODLE_ADMIN_EMAIL"    = var.moodle_admin_email
    "MOODLE_SITE_NAME"      = var.moodle_site_name
    
    # Storage configuration for Moodle - using direct reference to avoid deprecation
    "STORAGE_ACCOUNT_NAME"       = var.storage_account_name
    "STORAGE_ACCOUNT_KEY"        = var.storage_account_key
    "MOODLE_DATA_CONTAINER_NAME" = var.moodle_data_container_name
    
    # Misc configurations
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    
    # PHP configuration for better performance
    "PHP_MEMORY_LIMIT"      = "256M"
    "PHP_MAX_EXECUTION_TIME" = "600"
    "PHP_POST_MAX_SIZE"     = "100M"
    "PHP_UPLOAD_MAX_FILESIZE" = "100M"
  }

  # VNET integration is now configured in the main site_config block above

  # Enable managed identity for the web app
  # This will allow the web app to access other Azure resources securely
  identity {
    type = "SystemAssigned"
  }

  # Configure logs
  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  tags = {
    environment = var.environment
    project     = var.project_name
  }
  
  # This is the Moodle deployment script that will be executed
  # during the deployment of the web app
  provisioner "local-exec" {
    command = <<EOT
      echo "Deploying Moodle to Azure App Service..."
      # In a real implementation, you would include a script to:
      # 1. Download the latest Moodle version
      # 2. Configure it with the environment variables
      # 3. Deploy it to the App Service using FTP, Git, or ZIP deploy
      # For demonstration purposes, this is left as a placeholder
    EOT
  }

  depends_on = [
    azurerm_service_plan.moodle_plan
  ]
}

# Add custom domain if needed
# resource "azurerm_app_service_custom_hostname_binding" "moodle_hostname" {
#   hostname            = "moodle.yourdomain.com"
#   app_service_name    = azurerm_app_service.moodle_app.name
#   resource_group_name = var.resource_group_name
# }

# Add SSL certificate if needed
# resource "azurerm_app_service_certificate" "moodle_cert" {
#   name                = "${var.project_name}-cert"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   pfx_blob            = filebase64("path/to/certificate.pfx")
#   password            = var.certificate_password
# }