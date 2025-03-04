variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "db_server_name" {
  description = "Name for the PostgreSQL server"
  type        = string
}

variable "db_name" {
  description = "Name for the Moodle database"
  type        = string
}

variable "db_admin_username" {
  description = "Username for the database administrator"
  type        = string
}

variable "db_admin_password" {
  description = "Password for the database administrator"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "ID of the subnet to allow connections from"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "ID of the subnet to deploy private endpoints to"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM to allow connections from"
  type        = string
  default     = "moodle-vm"
}

# This variable allows us to create a dependency between the VM and the database firewall rule
variable "vm_depends_on" {
  description = "Resource the database depends on (typically the VM)"
  type        = any
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}