module "aws_vpc" {
  source = "./modules/aws/vpc"
  providers = {
    aws = aws
  }
  aws_region = "ca-central-1"
}

module "aws_ec2_a" {
  source          = "./modules/aws/ec2"
  providers       = { aws = aws }
  vpc_id          = module.aws_vpc.vpc_id
  subnet_ids      = [module.aws_vpc.public_subnet_a_id]
  security_group  = module.aws_vpc.security_group_id
}

module "aws_ec2_b" {
  source          = "./modules/aws/ec2"
  providers       = { aws = aws }
  vpc_id          = module.aws_vpc.vpc_id
  subnet_ids      = [module.aws_vpc.public_subnet_b_id]
  security_group  = module.aws_vpc.security_group_id
}

module "aws_ec2_c" {
  source          = "./modules/aws/ec2"
  providers       = { aws = aws }
  vpc_id          = module.aws_vpc.vpc_id
  subnet_ids     = [module.aws_vpc.public_subnet_c_id]
  security_group  = module.aws_vpc.security_group_id
}
module "aws_lb" {
  source = "./modules/aws/lb"
  providers = {
    aws = aws
  }
  vpc_id         = module.aws_vpc.vpc_id
  subnet_ids     = module.aws_vpc.subnet_ids
  security_group = module.aws_vpc.security_group_id
}

module "aws_autoscaling" {
  source = "./modules/aws/autoscaling"
  providers = {
    aws = aws
  }
  target_group_arn  = module.aws_lb.target_group_arn
  subnet_ids        = module.aws_vpc.subnet_ids
  security_group    = module.aws_vpc.security_group_id
}

module "aws_cloudwatch" {
  source = "./modules/aws/cloudwatch"
  providers = {
    aws = aws
  }
  asg_name           = module.aws_autoscaling.asg_name
  scale_up_policy_arn = module.aws_autoscaling.scale_up_policy_arn
  scale_down_policy_arn = module.aws_autoscaling.scale_down_policy_arn
}


############################################Azure part###########################################
module "azure_vnet" {
  source = "./modules/azure/vnet"
  providers = {
    azurerm = azurerm
  }
  azure_location      = "Canada Central"
  resource_group_name = "my-resource-group"
}

module "azure_compute_a" {
  source     = "./modules/azure/compute"
  providers  = { azurerm = azurerm }
  azure_location      = module.azure_vnet.azure_location
  resource_group_name = module.azure_vnet.resource_group_name
  subnet_id           = module.azure_vnet.public_subnet_a_id
  vnet_id             = module.azure_vnet.vnet_id
}

module "azure_compute_b" {
  source     = "./modules/azure/compute"
  providers  = { azurerm = azurerm }
  azure_location      = module.azure_vnet.azure_location
  resource_group_name = module.azure_vnet.resource_group_name
  subnet_id           = module.azure_vnet.public_subnet_b_id
  vnet_id             = module.azure_vnet.vnet_id
}

module "azure_compute_c" {
  source     = "./modules/azure/compute"
  providers  = { azurerm = azurerm }
  azure_location      = module.azure_vnet.azure_location
  resource_group_name = module.azure_vnet.resource_group_name
  subnet_id           = module.azure_vnet.public_subnet_c_id
  vnet_id             = module.azure_vnet.vnet_id
}

module "azure_lb" {
  source = "./modules/azure/lb"
  providers = {
    azurerm = azurerm
  }
  azure_location      = module.azure_vnet.azure_location
  resource_group_name = module.azure_vnet.resource_group_name
  vnet_id             = module.azure_vnet.vnet_id
  subnet_ids          = module.azure_vnet.subnet_ids
}

module "azure_autoscaling" {
  source = "./modules/azure/scaling"
  providers = {
    azurerm = azurerm
  }
  azure_location      = module.azure_vnet.azure_location
  resource_group_name = module.azure_vnet.resource_group_name
  compute_ids         = [
    module.azure_compute_a.compute_id,
    module.azure_compute_b.compute_id,
    module.azure_compute_c.compute_id
  ]
  lb_backend_id       = module.azure_lb.lb_backend_id
}
