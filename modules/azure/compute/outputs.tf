output "vmss_id" {
  value = azurerm_virtual_machine_scale_set.main.id
}

# output "vmss_public_ips" {
#   value = azurerm_virtual_machine_scale_set.main.public_ip_addresses
# }
# output "vmss_public_ips" {
#   value = data.external.vmss_ips.result
# }
output "vmss_name" {
  value = azurerm_virtual_machine_scale_set.main.name
}
