variable "azure_location" {
  description = "The Azure location to deploy to"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the VNet"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance in"
  type        = string
}
