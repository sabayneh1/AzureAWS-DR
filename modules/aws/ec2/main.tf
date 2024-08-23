
# modules/aws/ec2/main.tf
resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "${var.launch_template_name}-"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group]
    device_index                = 0
  }
}
