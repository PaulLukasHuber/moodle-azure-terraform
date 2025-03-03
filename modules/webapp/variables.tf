variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "app_service_plan_tier" {
  description = "Tier for App Service Plan"
  type        = string
}

variable "app_service_plan_size" {
  description = "Size for App Service Plan"
  type        = string
}

variable "mysql_server_fqdn" {
  description = "FQDN of the MySQL server"
  type        = string
}

variable "mysql_database_name" {
  description = "Name of the Moodle database"
  type        = string
}

variable "mysql_admin_username" {
  description = "MySQL administrator username"
  type        = string
}

variable "mysql_admin_password" {
  description = "MySQL administrator password"
  type        = string
}

variable "moodle_site_name" {
  description = "Moodle site name"
  type        = string
}

variable "moodle_admin_email" {
  description = "Moodle admin email"
  type        = string
}

variable "moodle_admin_user" {
  description = "Moodle admin username"
  type        = string
}

variable "moodle_admin_password" {
  description = "Moodle admin password"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Storage Account"
  type        = string
}

variable "storage_account_key" {
  description = "Access key for the Storage Account"
  type        = string
}

variable "moodle_data_container_name" {
  description = "Name of the Moodle data container"
  type        = string
}

variable "web_subnet_id" {
  description = "ID of the web subnet"
  type        = string
}