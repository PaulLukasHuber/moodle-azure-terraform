variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
}

variable "vm_id" {
  description = "ID of the virtual machine to secure"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets used in the deployment"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}