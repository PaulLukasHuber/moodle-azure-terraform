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

variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = list(string)
}

variable "web_subnet_address_prefix" {
  description = "Address prefix for web subnet"
  type        = string
}

variable "db_subnet_address_prefix" {
  description = "Address prefix for database subnet"
  type        = string
}