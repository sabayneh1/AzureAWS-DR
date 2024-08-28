# #unset TF_LOG
# #export TF_LOG=TRACE
# main.tf

# VNet Module
module "azure_vnet" {
  source              = "./modules/vnet"
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
  source              = "./modules/compute"
  azure_location      = var.azure_location
  resource_group_name = var.resource_group_name
  subnet_id           = module.azure_vnet.subnet_ids[0]
  vnet_id             = module.azure_vnet.vnet_id
  unique_suffix       = random_string.suffix.result
  vmss_name           = "myvmss"
  nsg_id              = module.azure_vnet.nsg_id
  lb_backend_id       = module.azure_lb.lb_backend_id
  depends_on          = [module.azure_vnet]
}

# Load Balancer Module
module "azure_lb" {
  source              = "./modules/lb"
  azure_location      = var.azure_location
  resource_group_name = var.resource_group_name
  vnet_id             = module.azure_vnet.vnet_id
  subnet_ids          = module.azure_vnet.subnet_ids
  depends_on          = [module.azure_vnet]
}

# Autoscaling Module
module "azure_autoscaling" {
  source              = "./modules/scaling"
  azure_location      = var.azure_location
  resource_group_name = var.resource_group_name
  vmss_id             = module.azure_compute_vmss.vmss_id
  lb_backend_id       = module.azure_lb.lb_backend_id
  depends_on          = [module.azure_vnet, module.azure_compute_vmss, module.azure_lb]
}



################################################

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
