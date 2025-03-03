output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.moodle_vnet.id
}

output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = azurerm_subnet.web_subnet.id
}

output "db_subnet_id" {
  description = "ID of the database subnet"
  value       = azurerm_subnet.db_subnet.id
}

output "web_nsg_id" {
  description = "ID of the web NSG"
  value       = azurerm_network_security_group.web_nsg.id
}

output "db_nsg_id" {
  description = "ID of the database NSG"
  value       = azurerm_network_security_group.db_nsg.id
}