# #unset TF_LOG
# #export TF_LOG=TRACE
# main.tf
module "aws_vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
}

module "aws_lb" {
  source = "./modules/lb"
  vpc_id = module.aws_vpc.vpc_id
  subnet_ids = [
    module.aws_vpc.public_subnet_a_id,
    module.aws_vpc.public_subnet_b_id,
    module.aws_vpc.public_subnet_c_id
  ]
  security_group = module.aws_vpc.security_group_id
}

module "aws_ec2" {
  source               = "./modules/ec2"
  launch_template_name = "my_launch_template"
  image_id             = "ami-0c9f6749650d5c0e3"
  instance_type        = "t3.micro"
  key_name             = "ubuntu"
  volume_size          = 8
  volume_type          = "gp2"
  security_group       = module.aws_vpc.security_group_id
}

module "aws_autoscaling" {
  source             = "./modules/autoscaling"
  launch_template_id = module.aws_ec2.launch_template_id
  subnet_ids = [
    module.aws_vpc.public_subnet_a_id,
    module.aws_vpc.public_subnet_b_id,
    module.aws_vpc.public_subnet_c_id
  ]
  target_group_arn = module.aws_lb.target_group_arn
}


module "aws_cloudwatch" {
  source                        = "./modules/cloudwatch"
  asg_name                      = module.aws_autoscaling.asg_name
  scale_up_policy_arn           = module.aws_autoscaling.scale_up_policy_arn
  scale_down_policy_arn         = module.aws_autoscaling.scale_down_policy_arn
  alb_name                      = module.aws_lb.alb_name
  lambda_function_arn           = module.lambda_disaster_recovery.lambda_function_arn
  lambda_function_function_name = module.lambda_disaster_recovery.lambda_function_function_name
  depends_on                    = [module.aws_vpc, module.aws_autoscaling, module.aws_ec2, module.aws_lb, module.lambda_disaster_recovery]

}

module "lambda_disaster_recovery" {
  source      = "./modules/lambda_disaster_recovery"
  github_repo = "https://github.com/sabayneh1/AzureAWS-DR.git"
  depends_on  = [module.aws_vpc, module.aws_autoscaling, module.aws_ec2, module.aws_lb]
}

################################################

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/templates/ansible_inventory.tpl", {
    aws_public_ips = module.aws_autoscaling.asg_instance_public_ips,
  })
  filename = "${path.module}/ansible/inventory"
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.ansible_inventory.filename} /home/sam/Multi-CloudDisasterRecovery/multi-Cloud-DR/AWS/ansible/site.yml"
  }

  triggers = {
    aws_ips = join(",", module.aws_autoscaling.asg_instance_public_ips)
  }

  depends_on = [
    module.aws_vpc,
    module.aws_lb,
    module.aws_ec2,
    module.aws_autoscaling,
    module.aws_cloudwatch,
    module.lambda_disaster_recovery,
    local_file.ansible_inventory
  ]
}


