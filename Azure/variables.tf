variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "ca-central-1"
}

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

