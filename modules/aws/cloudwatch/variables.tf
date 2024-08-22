variable "asg_name" {
  description = "The name of the Auto Scaling group to monitor"
  type        = string
}

variable "scale_up_policy_arn" {
  description = "The ARN of the scale up policy"
  type        = string
}

variable "scale_down_policy_arn" {
  description = "The ARN of the scale down policy"
  type        = string
}


# ALB Name
variable "alb_name" {
  description = "The name of the Application Load Balancer"
  type        = string
}


variable "lambda_function_arn" {
  description = "The name of the Application Load Balancer"
  type        = string
}

variable "lambda_function_function_name" {
  description = "The name of the Application Load Balancer"
  type        = string
}
