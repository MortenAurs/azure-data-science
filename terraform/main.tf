# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.37.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  address_space       = ["10.10.0.0/22"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "aml" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.10.0.0/24"]
  service_endpoints    = [ "Microsoft.Storage", "Microsoft.ContainerRegistry" ]
}

resource "azurerm_application_insights" "this" {
  name                = var.application_insights_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "web"
}

resource "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "premium"
}

resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.aml.id]
  }
}

resource "azurerm_container_registry" "this" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Premium"
  admin_enabled       = false

  network_rule_set {
      default_action = "Deny"
      virtual_network {
        action = "Allow"
        subnet_id = azurerm_subnet.aml.id
      } 
  }
}

resource "azurerm_machine_learning_workspace" "this" {
  name                          = var.machine_learning_workspace_name
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  application_insights_id       = azurerm_application_insights.this.id
  key_vault_id                  = azurerm_key_vault.this.id
  storage_account_id            = azurerm_storage_account.this.id
  public_network_access_enabled = true
  container_registry_id         = azurerm_container_registry.this.id
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_machine_learning_compute_instance" "example" {
  name                          = var.machine_learning_compute_instance_name
  location                      = azurerm_resource_group.this.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.this.id
  virtual_machine_size          = "STANDARD_DS11_V2"
  subnet_resource_id            = azurerm_subnet.aml.id
  description                   = "Azure ML to test while doing the AZ Data Science certification"
}

#######################################
## P R I V A T E   E N D P O I N T S ##
#######################################

resource "azurerm_private_endpoint" "acr" {
  name                          = "pe-${var.container_registry_name}"
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "nic-pe-${var.container_registry_name}"
  private_service_connection {
    name                           = "psc-${var.container_registry_name}"
    private_connection_resource_id = azurerm_container_registry.this.id
    is_manual_connection           = false
    subresource_names              = ["registry"] 
  }
}

resource "azurerm_private_endpoint" "blob" {
  name                          = "pe-${var.storage_account_name}-blob"
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "nic-pe-${var.storage_account_name}-blob"
  private_service_connection {
    name                           = "psc-${var.storage_account_name}-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"] 
  }
}

resource "azurerm_private_endpoint" "file" {
  name                          = "pe-${var.storage_account_name}-file"
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "nic-pe-${var.storage_account_name}-file"
  private_service_connection {
    name                           = "psc-${var.storage_account_name}-file"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["file"] 
  }
}

resource "azurerm_private_endpoint" "table" {
  name                          = "pe-${var.storage_account_name}-table"
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "nic-pe-${var.storage_account_name}-table"
  private_service_connection {
    name                           = "psc-${var.storage_account_name}-table"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["table"] 
  }
}

resource "azurerm_private_endpoint" "amlw" {
  name                          = "pe-${var.machine_learning_workspace_name}"
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "nic-pe-${var.machine_learning_workspace_name}"
  private_service_connection {
    name                           = "psc-${var.machine_learning_workspace_name}"
    private_connection_resource_id = azurerm_machine_learning_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["amlworkspace"] 
  }
}

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

  amount     = 200
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
    enabled   = false
    threshold = 100.0
    operator  = "GreaterThan"

    contact_groups = [
      azurerm_monitor_action_group.owner.id,
    ]
  }
}