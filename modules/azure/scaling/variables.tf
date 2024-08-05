variable "azure_location" {
  description = "The Azure location to deploy to"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources"
  type        = string
}

variable "compute_ids" {
  description = "The IDs of the compute resources to be scaled"
  type        = list(string)
}

variable "lb_backend_id" {
  description = "The ID of the load balancer backend pool"
  type        = string
}
