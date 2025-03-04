# General variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "moodle-resources"
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "development"
    project     = "moodle-lms"
  }
}

# Networking variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "moodle-vnet"
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Address prefixes for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "subnet_names" {
  description = "Names for subnets"
  type        = list(string)
  default     = ["web-subnet", "db-subnet", "pe-subnet"]
}

# Storage variables
variable "storage_account_name" {
  description = "Name of the storage account for Moodle files"
  type        = string
  default     = "moodlestorage"
}

# Database variables
variable "db_server_name" {
  description = "Name for the PostgreSQL server"
  type        = string
  default     = "moodle-postgres"
}

variable "db_name" {
  description = "Name for the Moodle database"
  type        = string
  default     = "moodledb"
}

variable "db_admin_username" {
  description = "Username for the database administrator"
  type        = string
  default     = "moodleadmin"
}

variable "db_admin_password" {
  description = "Password for the database administrator"
  type        = string
  sensitive   = true
}

# Compute variables
variable "vm_name" {
  description = "Name for the Moodle VM"
  type        = string
  default     = "moodle-vm"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1ms"  # Budget-friendly size
}

variable "vm_admin_username" {
  description = "Username for the VM administrator"
  type        = string
  default     = "azureadmin"
}

variable "vm_admin_password" {
  description = "Password for the VM administrator"
  type        = string
  sensitive   = true
}

# Moodle variables
variable "moodle_admin_email" {
  description = "Email for the Moodle administrator"
  type        = string
  default     = "admin@example.com"
}

variable "moodle_admin_user" {
  description = "Username for the Moodle administrator"
  type        = string
  default     = "admin"
}

variable "moodle_admin_password" {
  description = "Password for the Moodle administrator"
  type        = string
  sensitive   = true
}

variable "moodle_site_name" {
  description = "Site name for the Moodle installation"
  type        = string
  default     = "Moodle LMS"
}