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

variable "storage_account_tier" {
  description = "Tier for Storage Account"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Replication type for Storage Account"
  type        = string
  default     = "LRS"
}