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

variable "mysql_server_name" {
  description = "Name of the MySQL server"
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

variable "mysql_version" {
  description = "MySQL version"
  type        = string
}

variable "mysql_sku_name" {
  description = "MySQL SKU Name"
  type        = string
}

variable "mysql_storage_mb" {
  description = "MySQL Storage in MB"
  type        = number
}

variable "web_subnet_id" {
  description = "ID of the web subnet"
  type        = string
}

variable "virtual_network_id" {
  description = "ID of the virtual network"
  type        = string
}