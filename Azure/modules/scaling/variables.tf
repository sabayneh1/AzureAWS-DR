variable "azure_location" {
  description = "The Azure location to deploy to"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
  type        = string
}

variable "lb_backend_id" {
  description = "The ID of the load balancer backend pool"
  type        = string
}

variable "vmss_id" {
  description = "The ID of the Virtual Machine Scale Set to be scaled"
  type        = string
}

