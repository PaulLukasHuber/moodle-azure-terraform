# =================================================================
# SECURITY MODULE - MAIN CONFIGURATION
# =================================================================
# This module creates resources for monitoring and securing the
# Moodle deployment, including alerts and action groups
# =================================================================

# Create Azure Monitor action group for alerts
# This defines who gets notified when alerts are triggered
resource "azurerm_monitor_action_group" "vm_action_group" {
  name                = "moodle-vm-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "moodlevm"  # Limited to 12 characters
  
  # Email receiver for alerts - replace with actual email in production
  email_receiver {
    name          = "admin"
    email_address = "admin@example.com"  # Replace with actual email address
  }
}

# =================================================================
# MONITORING ALERTS
# =================================================================

# Create VM CPU alert to detect high CPU usage
# This helps monitor performance and identify potential issues
resource "azurerm_monitor_metric_alert" "vm_cpu_alert" {
  name                = "moodle-vm-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]  # Monitor this specific VM
  description         = "Alert when VM CPU exceeds 80%"
  severity            = 2            # Warning level (0-4, with 0 being critical)

  # Alert criteria definition
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"  # Resource type
    metric_name      = "Percentage CPU"                     # Metric to monitor
    aggregation      = "Average"                            # Use average over time period
    operator         = "GreaterThan"                        # Trigger when greater than threshold
    threshold        = 80                                   # 80% CPU usage threshold
  }

  # Action to take when alert triggers
  action {
    action_group_id = azurerm_monitor_action_group.vm_action_group.id
  }

  # Note: Additional monitoring such as memory, disk, or network
  # alerts could be added here for more comprehensive monitoring
}