output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "subnet_ids" {
  value = [azurerm_subnet.public_a.id, azurerm_subnet.public_b.id, azurerm_subnet.public_c.id]
}

output "public_subnet_a_id" {
  value = azurerm_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = azurerm_subnet.public_b.id
}

output "public_subnet_c_id" {
  value = azurerm_subnet.public_c.id
}
