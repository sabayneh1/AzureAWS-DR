variable "azure_location" {
  description = "The Azure location to deploy to"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs to associate with the load balancer"
  type        = list(string)
}

variable "vnet_id" {
  description = "The VNet ID where the load balancer will be created"
  type        = string
}
