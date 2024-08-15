#unset TF_LOG
#export TF_LOG=TRACE
module "aws_vpc" {
  source = "./modules/aws/vpc"
  # providers = {
  #   aws = aws
  # }
  aws_region = var.aws_region
}

# Add this to your main.tf to generate unique suffixes
resource "random_string" "suffix_a" {
  length  = 6
  special = false
}

resource "random_string" "suffix_b" {
  length  = 6
  special = false
}

resource "random_string" "suffix_c" {
  length  = 6
  special = false
}

# Example of using the unique suffix in the EC2 module
module "aws_ec2_a" {
  source          = "./modules/aws/ec2"
  vpc_id          = module.aws_vpc.vpc_id
  subnet_ids      = [module.aws_vpc.public_subnet_a_id]
  security_group  = module.aws_vpc.security_group_id
  launch_template_name = "my_launch_template-${random_string.suffix_a.result}"  # This will be used as a prefix
  depends_on = [module.aws_vpc]
}

module "aws_ec2_b" {
  source          = "./modules/aws/ec2"
  vpc_id          = module.aws_vpc.vpc_id
  subnet_ids      = [module.aws_vpc.public_subnet_b_id]
  security_group  = module.aws_vpc.security_group_id
  launch_template_name = "my_launch_template-${random_string.suffix_b.result}"
  depends_on = [module.aws_vpc]
}

module "aws_ec2_c" {
  source          = "./modules/aws/ec2"
  vpc_id          = module.aws_vpc.vpc_id
  subnet_ids      = [module.aws_vpc.public_subnet_c_id]
  security_group  = module.aws_vpc.security_group_id
  launch_template_name = "my_launch_template-${random_string.suffix_c.result}"
  depends_on = [module.aws_vpc]
}



module "aws_lb" {
  source = "./modules/aws/lb"
  # providers = {
  #   aws = aws
  # }
  vpc_id         = module.aws_vpc.vpc_id
  subnet_ids     = module.aws_vpc.subnet_ids
  security_group = module.aws_vpc.security_group_id
  depends_on = [ module.aws_vpc ]
}

module "aws_autoscaling" {
  source            = "./modules/aws/autoscaling"
  target_group_arn  = module.aws_lb.target_group_arn
  subnet_ids        = module.aws_vpc.subnet_ids
  security_group    = module.aws_vpc.security_group_id
  depends_on        = [module.aws_vpc, module.aws_lb]
}




module "aws_cloudwatch" {
  source = "./modules/aws/cloudwatch"
  # providers = {
  #   aws = aws
  # }
  asg_name           = module.aws_autoscaling.asg_name
  scale_up_policy_arn = module.aws_autoscaling.scale_up_policy_arn
  scale_down_policy_arn = module.aws_autoscaling.scale_down_policy_arn
  depends_on = [ module.aws_vpc, module.aws_autoscaling ]
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

data "template_file" "ansible_inventory" {
  template = file("${path.module}/ansible/templates/ansible_inventory.tpl")

  vars = {
    aws_public_ips  = module.aws_ec2_a.aws_instance_public_ip
    azure_vmss_ips  = module.azure_compute_vmss.public_ip
  }
}

resource "local_file" "ansible_inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "${path.module}/inventory/hosts"
}
