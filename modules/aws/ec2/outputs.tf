output "launch_template_id" {
  value = aws_launch_template.my_launch_template.id
}
output "aws_ec2_public_ips" {
  value = [aws_instance.my_instance.public_ip]
}
