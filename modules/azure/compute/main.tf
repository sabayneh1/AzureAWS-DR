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

#     # Associate the NSG directly here
#     network_security_group_id = var.nsg_id
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


resource "azurerm_virtual_machine_scale_set" "main" {
  name                = "${var.vmss_name}-${var.unique_suffix}"
  location            = var.azure_location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_D2s_v3"
    capacity = 2  # Initial instance count, can be scaled by autoscaling
    tier     = "Standard"
  }

  upgrade_policy_mode = "Manual"

  zones = ["1", "2", "3"]

  network_profile {
    name    = "vmss-nic-${var.unique_suffix}"
    primary = true

    ip_configuration {
      name      = "vmss-ip-config"
      subnet_id = var.subnet_id
      primary   = true
    }

    network_security_group_id = var.nsg_id
  }

  os_profile {
    computer_name_prefix = "vmss"
    admin_username       = "adminuser"
    admin_password       = "P@ssword1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  tags = {
    environment = "testing"
  }
}
