# outputs.tf

output "asg_public_ips" {
  value = module.aws_autoscaling.asg_instance_public_ips
  description = "Public IP addresses of instances in the Auto Scaling Group"
}
