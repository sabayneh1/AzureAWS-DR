output "aws_vpc_ids" {
  value = [
    module.aws_vpc_ca_central_1.vpc_id,
    module.aws_vpc_us_east_1.vpc_id,
    module.aws_vpc_us_west_2.vpc_id
  ]
}

output "aws_subnet_ids" {
  value = [
    module.aws_vpc_ca_central_1.subnet_ids,
    module.aws_vpc_us_east_1.subnet_ids,
    module.aws_vpc_us_west_2.subnet_ids
  ]
}

output "aws_security_group_ids" {
  value = [
    module.aws_vpc_ca_central_1.security_group_id,
    module.aws_vpc_us_east_1.security_group_id,
    module.aws_vpc_us_west_2.security_group_id
  ]
}

output "azure_vnet_ids" {
  value = [
    module.azure_vnet_canadacentral.vnet_id,
    module.azure_vnet_canadaeast.vnet_id,
    module.azure_vnet_centralus.vnet_id
  ]
}

output "azure_subnet_ids" {
  value = [
    module.azure_vnet_canadacentral.subnet_ids,
    module.azure_vnet_canadaeast.subnet_ids,
    module.azure_vnet_centralus.subnet_ids
  ]
}
