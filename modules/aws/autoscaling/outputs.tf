# output "asg_name" {
#   value = aws_autoscaling_group.my_asg.name
# }

# output "scale_up_policy_arn" {
#   value = aws_autoscaling_policy.scale_up.arn
# }

# output "scale_down_policy_arn" {
#   value = aws_autoscaling_policy.scale_down.arn
# }


# # Output the public IPs of instances in the Auto Scaling group
# output "asg_instance_public_ips" {
#   value = data.aws_instances.asg_instances.public_ips
# }
# modules/aws/autoscaling/outputs.tf
output "asg_name" {
  value = aws_autoscaling_group.my_asg.name
}

output "scale_up_policy_arn" {
  value = aws_autoscaling_policy.scale_up.arn
}

output "scale_down_policy_arn" {
  value = aws_autoscaling_policy.scale_down.arn
}


output "asg_instance_public_ips" {
  value = data.aws_instances.asg_instances.public_ips
  description = "Public IP addresses of instances in the Auto Scaling Group"
}

