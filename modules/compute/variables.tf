# Required variables for the compute module
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "vm_name" {
  description = "Name for the Moodle VM"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
}

variable "admin_username" {
  description = "Username for the VM administrator"
  type        = string
}

variable "admin_password" {
  description = "Password for the VM administrator"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "ID of the subnet to deploy the VM to"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account for Moodle files"
  type        = string
}

variable "storage_account_key" {
  description = "Access key for the storage account"
  type        = string
  sensitive   = true
}

variable "db_server_fqdn" {
  description = "FQDN of the PostgreSQL server"
  type        = string
}

variable "db_name" {
  description = "Name of the Moodle database"
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

variable "moodle_admin_email" {
  description = "Email for the Moodle administrator"
  type        = string
}

variable "moodle_admin_user" {
  description = "Username for the Moodle administrator"
  type        = string
}

variable "moodle_admin_password" {
  description = "Password for the Moodle administrator"
  type        = string
  sensitive   = true
}

variable "moodle_site_name" {
  description = "Site name for the Moodle installation"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}