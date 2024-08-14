# resource "azurerm_virtual_machine_scale_set" "main" {
#   name                = "${var.vmss_name}-${var.unique_suffix}"
#   location            = var.azure_location
#   resource_group_name = var.resource_group_name

#   sku {
#     name     = "Standard_D2s_v3"
#     capacity = 2  # Initial instance count, can be scaled by autoscaling
#     tier     = "Standard"
#   }

#   upgrade_policy_mode = "Manual"

#   zones = ["1", "2", "3"]

#   network_profile {
#     name    = "vmss-nic-${var.unique_suffix}"
#     primary = true

#     ip_configuration {
#       name      = "vmss-ip-config"
#       subnet_id = var.subnet_id
#       primary   = true

#       public_ip_address_configuration {
#         name               = "vmss-public-ip"
#         domain_name_label  = lower("${var.vmss_name}-${var.unique_suffix}")
#         idle_timeout       = 4  # Idle timeout in minutes
#       }
#     }
#   }

#   os_profile {
#     computer_name_prefix = "vmss"
#     admin_username       = "adminuser"
#     admin_password       = "P@ssword1234!"
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   storage_profile_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "18.04-LTS"
#     version   = "latest"
#   }


#   storage_profile_os_disk {
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }
#   tags = {
#     environment = "testing"
#   }
# }




resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = var.azure_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_virtual_machine" "example" {
  name                  = "example-machine"
  location              = var.azure_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "adminuser"
    admin_password = "P@ssword1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i '${azurerm_public_ip.example.ip_address},' -u adminuser --private-key /path/to/your/private/key /home/sam/Multi-CloudDisasterRecovery/multi-Cloud-DR/ansible/site.yml
    EOT
  }

  tags = {
    environment = "testing"
  }
}

output "public_ip" {
  value = azurerm_public_ip.example.ip_address
}
