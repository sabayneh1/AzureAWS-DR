resource "random_string" "suffix" {
  length  = 6
  special = false
}

# Launch Template Resource
resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "my-launch-template-${random_string.suffix.result}"
  image_id      = "ami-0c9f6749650d5c0e3"
  instance_type = "t2.micro"
  key_name      = "ubuntu"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group]
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "my-asg-instance"
    }
  }
}
# Auto Scaling Group Resource
resource "aws_autoscaling_group" "my_asg" {
  name                = "my_asg"
  max_size            = 5
  min_size            = 2
  health_check_type   = "ELB"
  desired_capacity    = 2
  target_group_arns   = [var.target_group_arn]
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "my-asg-instance"
    propagate_at_launch = true
  }
}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}
