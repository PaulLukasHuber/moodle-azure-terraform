variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
  default     = "moodle"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "moodle-rg"
}

# Network variables
variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "web_subnet_address_prefix" {
  description = "Address prefix for web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet_address_prefix" {
  description = "Address prefix for database subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# Database variables
variable "mysql_server_name" {
  description = "Name of the MySQL server"
  type        = string
  default     = "moodle-mysql"
}

variable "mysql_admin_username" {
  description = "MySQL administrator username"
  type        = string
  default     = "moodleadmin"
  sensitive   = true
}

variable "mysql_admin_password" {
  description = "MySQL administrator password"
  type        = string
  sensitive   = true
}

# Note: These variables are kept for compatibility but actual values are hardcoded in the module
variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "8.0.21"
}

variable "mysql_sku_name" {
  description = "MySQL SKU Name"
  type        = string
  default     = "B_Standard_B1s" # Basic tier, most economical option
}

variable "mysql_storage_mb" {
  description = "MySQL Storage in MB"
  type        = number
  default     = 20480 # 20GB, minimum required
}

# Web App variables
variable "app_service_plan_tier" {
  description = "Tier for App Service Plan"
  type        = string
  default     = "Basic" # Basic tier for cost optimization
}

variable "app_service_plan_size" {
  description = "Size/SKU for App Service Plan (e.g. B1, S1, P1v2)"
  type        = string
  default     = "B1" # Basic small instance
}

# Moodle config variables
variable "moodle_site_name" {
  description = "Moodle site name"
  type        = string
  default     = "Moodle LMS"
}

variable "moodle_admin_email" {
  description = "Moodle admin email"
  type        = string
  default     = "admin@example.com"
}

variable "moodle_admin_user" {
  description = "Moodle admin username"
  type        = string
  default     = "admin"
}

variable "moodle_admin_password" {
  description = "Moodle admin password"
  type        = string
  sensitive   = true
}

# Storage variables
variable "storage_account_tier" {
  description = "Tier for Storage Account"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Replication type for Storage Account"
  type        = string
  default     = "LRS" # Locally redundant storage (lowest cost option)
}