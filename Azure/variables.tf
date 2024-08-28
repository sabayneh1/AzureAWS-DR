variable "azure_location" {
  description = "The Azure location to deploy to"
  type        = string
  default     = "Canada Central"
}

variable "resource_group_name" {
  description = "resouce group to deploy the code"
  type        = string
  default     = "forStringConnection"
}

