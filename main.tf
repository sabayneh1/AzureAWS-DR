# #unset TF_LOG
# #export TF_LOG=TRACE
# main.tf
module "aws_vpc" {
  source = "./modules/aws/vpc"
  aws_region = var.aws_region
}

module "aws_lb" {
  source = "./modules/aws/lb"
  vpc_id = module.aws_vpc.vpc_id
  subnet_ids = [
    module.aws_vpc.public_subnet_a_id,
    module.aws_vpc.public_subnet_b_id,
    module.aws_vpc.public_subnet_c_id
  ]
  security_group = module.aws_vpc.security_group_id
}

module "aws_ec2" {
  source = "./modules/aws/ec2"
  launch_template_name = "my_launch_template"
  image_id = "ami-0c9f6749650d5c0e3"
  instance_type = "t3.micro"
  key_name = "ubuntu"
  volume_size = 8
  volume_type = "gp2"
  security_group = module.aws_vpc.security_group_id
}

module "aws_autoscaling" {
  source = "./modules/aws/autoscaling"
  launch_template_id = module.aws_ec2.launch_template_id
  subnet_ids = [
    module.aws_vpc.public_subnet_a_id,
    module.aws_vpc.public_subnet_b_id,
    module.aws_vpc.public_subnet_c_id
  ]
  target_group_arn = module.aws_lb.target_group_arn
}


module "aws_cloudwatch" {
  source                = "./modules/aws/cloudwatch"
  asg_name              = module.aws_autoscaling.asg_name
  scale_up_policy_arn   = module.aws_autoscaling.scale_up_policy_arn
  scale_down_policy_arn = module.aws_autoscaling.scale_down_policy_arn
  alb_name              = module.aws_lb.alb_name
  lambda_function_arn = module.lambda_disaster_recovery.lambda_function_arn
  lambda_function_function_name = module.lambda_disaster_recovery.lambda_function_function_name
  depends_on = [ module.aws_vpc, module.aws_autoscaling,module.aws_ec2,module.aws_lb,module.lambda_disaster_recovery ]

}

module "lambda_disaster_recovery" {
  source      = "./modules/aws/lambda_disaster_recovery"
  github_repo = "https://github.com/sabayneh1/AzureAWS-DR.git"
  depends_on = [ module.aws_vpc, module.aws_autoscaling,module.aws_ec2,module.aws_lb]
}



############################################Azure part###########################################
# VNet Module
module "azure_vnet" {
  source              = "./modules/azure/vnet"
  azure_location      = var.azure_location
  resource_group_name = var.resource_group_name
}

# Random Suffix for Resource Naming
resource "random_string" "suffix" {
  length  = 6
  special = false
}

# VM Scale Set Module
module "azure_compute_vmss" {
  source              = "./modules/azure/compute"
  azure_location      = var.azure_location
  resource_group_name = var.resource_group_name
  subnet_id           = module.azure_vnet.subnet_ids[0]
  vnet_id             = module.azure_vnet.vnet_id
  unique_suffix       = random_string.suffix.result
  vmss_name           = "myvmss"
  nsg_id              = module.azure_vnet.nsg_id
  depends_on          = [module.azure_vnet]
}

# Load Balancer Module
module "azure_lb" {
  source              = "./modules/azure/lb"
  azure_location      = var.azure_location
  resource_group_name = var.resource_group_name
  vnet_id             = module.azure_vnet.vnet_id
  subnet_ids          = module.azure_vnet.subnet_ids
  depends_on          = [module.azure_vnet]
}

# Autoscaling Module
module "azure_autoscaling" {
  source              = "./modules/azure/scaling"
  azure_location      = var.azure_location
  resource_group_name = var.resource_group_name
  vmss_id             = module.azure_compute_vmss.vmss_id
  lb_backend_id       = module.azure_lb.lb_backend_id
  depends_on          = [module.azure_vnet, module.azure_compute_vmss, module.azure_lb]
}



################################################

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/templates/ansible_inventory.tpl", {
    aws_public_ips   = module.aws_autoscaling.asg_instance_public_ips,
    azure_vmss_ips   = []  # No Azure IPs when targeting AWS
  })
  filename = "${path.module}/ansible/inventory"
}
resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.ansible_inventory.filename} /home/sam/Multi-CloudDisasterRecovery/multi-Cloud-DR/ansible/site.yml"
  }

  triggers = {
    aws_ips = join(",", module.aws_autoscaling.asg_instance_public_ips)
  }

  depends_on = [
    module.aws_vpc,
    module.aws_lb,
    module.aws_ec2,
    module.aws_autoscaling,
    local_file.ansible_inventory
  ]
}





# Data source to retrieve VMSS IPs


# data "aws_instances" "asg_instances" {
#   filter {
#     name   = "tag:Name"
#     values = ["my-asg-instance"]
#   }
# }

# # Data source to retrieve VMSS IPs
# data "external" "vmss_ips" {
#   program = ["bash", "${path.module}/scripts/get_vmss_ips.sh"]

#   query = {
#     resource_group = var.resource_group_name
#     vmss_name      = module.azure_compute_vmss.vmss_name
#     # vmss_name           = "myvmss"
#   }

#   depends_on = [module.azure_compute_vmss]
# }
# # Ansible Inventory File creation
# data "template_file" "ansible_inventory" {
#   template = file("${path.module}/ansible/templates/ansible_inventory.tpl")

#   vars = {
#     aws_public_ips  = join(",", data.aws_instances.asg_instances.public_ips)
#     azure_vmss_ips  = join(",", values(data.external.vmss_ips.result))
#   }
# }

# resource "local_file" "ansible_inventory" {
#   content  = data.template_file.ansible_inventory.rendered
#   filename = "${path.module}/ansible/inventory/hosts"
# }

# resource "null_resource" "run_ansible" {
#   provisioner "local-exec" {
#     command = "ansible-playbook -i ansible/inventory/hosts ansible/site.yml"
#   }

#   triggers = {
#     aws_ips   = join(",", data.aws_instances.asg_instances.public_ips)
#     azure_ips = join(",", values(data.external.vmss_ips.result))
#   }
#   depends_on = [local_file.ansible_inventory, data.external.vmss_ips]
# }
