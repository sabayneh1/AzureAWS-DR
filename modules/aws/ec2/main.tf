resource "aws_launch_template" "my_launch_template" {
  name_prefix   = "${var.launch_template_name}-"  # This will ensure uniqueness
  image_id      = "ami-0c9f6749650d5c0e3"
  instance_type = "t2.micro"
  key_name      = "ubuntu"

  
  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i '${self.public_ip},' -u ubuntu --private-key /home/sam/Multi-CloudDisasterRecovery/multi-Cloud-DR/ubuntu.pem /home/sam/Multi-CloudDisasterRecovery/multi-Cloud-DR/ansible/site.yml
    EOT
  }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group]
    network_interface_id = aws_launch_template.my_launch_template.id
    device_index         = 0
  }
}
