# =================================================================
# MAIN VARIABLES FILE
# =================================================================
# This file defines all variables that can be used for customizing
# the Moodle deployment. Values can be overridden in terraform.tfvars
# =================================================================

# =================================================================
# GENERAL CONFIGURATION VARIABLES
# =================================================================

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "moodle-resources"  # Use a descriptive name
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "westeurope"  # Change to a region closer to your users
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "development"
    project     = "moodle-lms"
  }
  # Tags help with resource organization and cost tracking
}

# =================================================================
# NETWORKING VARIABLES
# =================================================================

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "moodle-vnet"
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # Large CIDR block for VNet
}

variable "subnet_prefixes" {
  description = "Address prefixes for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  # Three subnets: web tier, database tier, and private endpoints
}

variable "subnet_names" {
  description = "Names for subnets"
  type        = list(string)
  default     = ["web-subnet", "db-subnet", "pe-subnet"]
  # Each subnet hosts different components of the architecture
}

# =================================================================
# STORAGE VARIABLES
# =================================================================

variable "storage_account_name" {
  description = "Name of the storage account for Moodle files"
  type        = string
  default     = "moodlestorage"  # Must be globally unique in Azure
}

# =================================================================
# DATABASE VARIABLES
# =================================================================

variable "db_server_name" {
  description = "Name for the PostgreSQL server"
  type        = string
  default     = "moodle-postgres"  # Must be globally unique in Azure
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
  sensitive   = true  # Marked as sensitive to avoid showing in logs
}

# =================================================================
# COMPUTE VARIABLES
# =================================================================

variable "vm_name" {
  description = "Name for the Moodle VM"
  type        = string
  default     = "moodle-vm"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1ms"  # Budget-friendly size for development
}

variable "vm_admin_username" {
  description = "Username for the VM administrator"
  type        = string
  default     = "azureadmin"
}

variable "vm_admin_password" {
  description = "Password for the VM administrator"
  type        = string
  sensitive   = true  # Marked as sensitive to avoid showing in logs
}

# =================================================================
# MOODLE APPLICATION VARIABLES
# =================================================================

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
  sensitive   = true  # Marked as sensitive to avoid showing in logs
}

variable "moodle_site_name" {
  description = "Site name for the Moodle installation"
  type        = string
  default     = "Moodle LMS"
}