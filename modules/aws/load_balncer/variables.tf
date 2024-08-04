variable "security_group" {
  description = "The security group to associate with the load balancer"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs to associate with the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where the load balancer will be created"
  type        = string
}
