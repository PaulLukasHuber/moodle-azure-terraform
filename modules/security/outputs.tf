output "diag_storage_account_id" {
  description = "ID of the diagnostics storage account"
  value       = azurerm_storage_account.diag_storage.id
}

output "diag_storage_account_name" {
  description = "Name of the diagnostics storage account"
  value       = azurerm_storage_account.diag_storage.name
}

output "action_group_id" {
  description = "ID of the monitoring action group"
  value       = azurerm_monitor_action_group.vm_action_group.id
}

output "vm_cpu_alert_id" {
  description = "ID of the VM CPU alert"
  value       = azurerm_monitor_metric_alert.vm_cpu_alert.id
}

/* Uncomment if backup is enabled
output "backup_vault_id" {
  description = "ID of the backup vault"
  value       = azurerm_recovery_services_vault.backup_vault.id
}

output "backup_policy_id" {
  description = "ID of the backup policy"
  value       = azurerm_backup_policy_vm.backup_policy.id
}
*/