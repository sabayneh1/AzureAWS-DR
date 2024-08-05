resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.azure_location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "public_a" {
  name                 = "public-subnet-a"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "public_b" {
  name                 = "public-subnet-b"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "public_c" {
  name                 = "public-subnet-c"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

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
