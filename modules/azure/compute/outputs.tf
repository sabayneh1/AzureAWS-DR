output "vmss_id" {
  value = azurerm_virtual_machine_scale_set.main.id
}

output "azure_vmss_public_ips" {
  value = azurerm_virtual_machine_scale_set.main.public_ip_address
}
