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