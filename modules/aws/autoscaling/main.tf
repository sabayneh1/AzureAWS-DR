resource "aws_autoscaling_group" "my_asg" {
  name                      = "my_asg"
  max_size                  = 5
  min_size                  = 2
  health_check_type         = "ELB"
  desired_capacity          = 2
  target_group_arns         = [var.target_group_arn]
  vpc_zone_identifier       = var.subnet_ids

  launch_configuration = aws_launch_configuration.my_launch_configuration.name

  tag {
    key                 = "Name"
    value               = "my-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "my_launch_configuration" {
  name          = "my-launch-configuration"
  image_id      = "ami-06878d265978313ca"
  instance_type = "t2.micro"
  key_name      = "ubuntu"
  security_groups = [var.security_group]

  user_data = filebase64("${path.module}/server.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

output "asg_name" {
  value = aws_autoscaling_group.my_asg.name
}

output "scale_up_policy_arn" {
  value = aws_autoscaling_policy.scale_up.arn
}

output "scale_down_policy_arn" {
  value = aws_autoscaling_policy.scale_down.arn
}
