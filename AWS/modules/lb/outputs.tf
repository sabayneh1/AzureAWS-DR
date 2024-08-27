# modules/aws/lb/outputs.tf
output "target_group_arn" {
  value = aws_lb_target_group.my_tg.arn
}


output "alb_name" {
  value = aws_lb.my_alb.name
  description = "The name of the Application Load Balancer"
}
