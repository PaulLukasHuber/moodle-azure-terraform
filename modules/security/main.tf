# Create a diagnostic setting for VM
resource "azurerm_monitor_diagnostic_setting" "vm_diag" {
  name                       = "vm-diagnostics"
  target_resource_id         = var.vm_id
  storage_account_id         = azurerm_storage_account.diag_storage.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Create a storage account for diagnostics (low cost)
resource "azurerm_storage_account" "diag_storage" {
  name                     = "moodlediag${random_string.diag_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"  # Lowest cost option
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

# Generate a random suffix for diagnostic storage
resource "random_string" "diag_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Create Azure Monitor action group (for alerts)
resource "azurerm_monitor_action_group" "vm_action_group" {
  name                = "moodle-vm-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "moodlevm"
  
  # Can be replaced with actual email 
  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"
  }
}

# Create VM CPU alert
resource "azurerm_monitor_metric_alert" "vm_cpu_alert" {
  name                = "moodle-vm-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when VM CPU exceeds 80%"
  severity            = 2  # Warning

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.vm_action_group.id
  }
}

# Enable Azure Backup for VM (optional - adds cost)
# Commented out to reduce costs, but can be enabled if needed
/*
resource "azurerm_recovery_services_vault" "backup_vault" {
  name                = "moodle-backup-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "backup_policy" {
  name                = "moodle-backup-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name
  
  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  
  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "vm_backup" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.backup_vault.name
  source_vm_id        = var.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.backup_policy.id
}
*/