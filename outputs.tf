output "aws_vpc_id" {
  value = module.aws_vpc.vpc_id
}

output "aws_subnet_ids" {
  value = module.aws_vpc.subnet_ids
}

output "aws_security_group_id" {
  value = module.aws_vpc.security_group_id
}

output "azure_vnet_id" {
  value = module.azure_vnet.vnet_id
}

output "azure_subnet_ids" {
  value = module.azure_vnet.subnet_ids
}
