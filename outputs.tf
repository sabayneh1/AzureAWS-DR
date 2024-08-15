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
output "vmss_id" {
  value = module.azure_compute_vmss.vmss_id
}


output "aws_public_ips" {
  value = module.aws_ec2_a.public_ip
}

output "azure_vmss_ips" {
  value = module.azure_compute_vmss.public_ip_address
}
