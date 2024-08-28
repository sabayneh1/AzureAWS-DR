terraform {
  backend "azurerm" {
    resource_group_name  = "forStringConnection"
    storage_account_name = "terraform2rg"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate" # This is the file name for the state file
  }
}
