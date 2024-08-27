resource "azurerm_monitor_autoscale_setting" "example" {
  name                = "autoscale-example"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  target_resource_id  = var.vmss_id  # Use the VMSS ID directly

  profile {
    name = "defaultProfile"
    capacity {
      default = "2"
      minimum = "2"
      maximum = "5"
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = var.vmss_id  # Use the VMSS ID directly
        operator           = "GreaterThan"
        statistic          = "Average"
        threshold          = 80
        time_grain         = "PT1M"
        time_window        = "PT5M"
        time_aggregation   = "Average"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = var.vmss_id  # Use the VMSS ID directly
        operator           = "LessThan"
        statistic          = "Average"
        threshold          = 20
        time_grain         = "PT1M"
        time_window        = "PT5M"
        time_aggregation   = "Average"
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}
