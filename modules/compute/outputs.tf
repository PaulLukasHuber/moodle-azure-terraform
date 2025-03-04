output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.moodle_vm.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.moodle_vm.name
}

output "public_ip_address" {
  description = "Public IP address of the virtual machine"
  value       = azurerm_public_ip.moodle_public_ip.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the public IP address"
  value       = azurerm_public_ip.moodle_public_ip.fqdn
}

output "private_ip_address" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_network_interface.moodle_nic.private_ip_address
}

output "vm_admin_username" {
  description = "Administrator username for the virtual machine"
  value       = var.admin_username
}