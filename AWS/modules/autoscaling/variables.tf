# variable "target_group_arn" {
#   description = "The ARN of the target group"
#   type        = string
# }

# variable "subnet_ids" {
#   description = "The list of subnet IDs"
#   type        = list(string)
# }

# variable "security_group" {
#   description = "The security group to associate with the instances"
#   type        = string
# }

# modules/aws/autoscaling/variables.tf
variable "launch_template_id" {}
variable "subnet_ids" {}
variable "target_group_arn" {}

