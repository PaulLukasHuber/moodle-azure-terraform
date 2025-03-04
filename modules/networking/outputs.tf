output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.moodle_vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.moodle_vnet.name
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = azurerm_subnet.subnets[*].id
}

output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = azurerm_subnet.subnets[0].id
}

output "db_subnet_id" {
  description = "ID of the database subnet"
  value       = azurerm_subnet.subnets[1].id
}

output "pe_subnet_id" {
  description = "ID of the private endpoint subnet"
  value       = azurerm_subnet.subnets[2].id
}

output "web_nsg_id" {
  description = "ID of the web tier network security group"
  value       = azurerm_network_security_group.web_nsg.id
}

output "db_nsg_id" {
  description = "ID of the database tier network security group"
  value       = azurerm_network_security_group.db_nsg.id
}