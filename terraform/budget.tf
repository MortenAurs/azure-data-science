#################
## B U D G E T ##
#################

resource "azurerm_monitor_action_group" "owner" {
  name                = "Owners Email Alert"
  resource_group_name = azurerm_resource_group.this.name
  short_name          = "owneremail"

  email_receiver {
    name          = "sendtoowner"
    email_address = "morten.aursland@gmail.com"
  }
}

resource "azurerm_consumption_budget_resource_group" "this" {
  name              = "resourceGroup forecast"
  resource_group_id = azurerm_resource_group.this.id

  amount     = 100
  time_grain = "Monthly"

  time_period {
    start_date = "2022-12-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "EqualTo"
    threshold_type = "Forecasted"

    contact_groups = [
      azurerm_monitor_action_group.owner.id,
    ]
  }

  notification {
    enabled   = true
    threshold = 100.0
    operator  = "GreaterThan"

    contact_groups = [
      azurerm_monitor_action_group.owner.id,
    ]
  }
}
