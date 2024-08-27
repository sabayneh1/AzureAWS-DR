# variable "vpc_id" {
#   description = "The ID of the VPC"
#   type        = string
# }

# variable "security_group" {
#   description = "The security group to associate with the EC2 instances"
#   type        = string
# }

# variable "subnet_ids" {
#   description = "The list of subnet IDs to launch resources in"
#   type        = list(string)
# }

# variable "launch_template_name" {
#   description = "The name of the launch template"
#   type        = string
# }

# modules/aws/ec2/variables.tf
variable "launch_template_name" {}
variable "image_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "volume_size" {}
variable "volume_type" {}
variable "security_group" {}
