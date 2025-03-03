output "web_app_id" {
  description = "ID of the Linux Web App"
  value       = azurerm_linux_web_app.moodle_app.id
}

output "web_app_name" {
  description = "Name of the Linux Web App"
  value       = azurerm_linux_web_app.moodle_app.name
}

output "web_app_default_hostname" {
  description = "Default hostname of the Linux Web App"
  value       = azurerm_linux_web_app.moodle_app.default_hostname
}

output "web_app_outbound_ip_addresses" {
  description = "Outbound IP addresses of the Linux Web App"
  value       = azurerm_linux_web_app.moodle_app.outbound_ip_addresses
}