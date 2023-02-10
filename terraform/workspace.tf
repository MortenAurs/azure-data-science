resource "azurerm_machine_learning_workspace" "this" {
  name                          = var.local.machine_learning_workspace_name
  location                      = var.location
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

resource "azurerm_machine_learning_compute_instance" "moaur" {
  name                          = var.machine_learning_compute_instance_name
  location                      = var.location
  machine_learning_workspace_id = azurerm_machine_learning_workspace.this.id
  virtual_machine_size          = "STANDARD_DS11_V2"
  subnet_resource_id            = azurerm_subnet.aml.id
  description                   = "Azure ML to test while doing the AZ Data Science certification"
  identity {
    type = "SystemAssigned"
  }
  assign_to_user {
    object_id = "4afbe840-6f29-4b44-ae68-f49c2eb6af62"
    tenant_id = "8f81da33-edad-4282-a064-189a62bcaf2b"
  }
}

resource "azurerm_private_endpoint" "amlw" {
  name                          = "${var.local.machine_learning_workspace_name}-pe"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "${var.local.machine_learning_workspace_name}-nic-pe"
  private_service_connection {
    name                           = "${var.local.machine_learning_workspace_name}-psc"
    private_connection_resource_id = azurerm_machine_learning_workspace.this.id
    is_manual_connection           = false
    subresource_names              = ["amlworkspace"]
  }
}

# DNS Zones

resource "azurerm_private_dns_zone" "ws_zone_api" {
  name                = "privatelink.api.azureml.ms"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone" "ws_zone_notebooks" {
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "ws_zone_api_link" {
  name                  = "${azurerm_private_dns_zone.ws_zone_api.name}_link_api"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.ws_zone_api.name
  virtual_network_id    = azurerm_virtual_network.aml_vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "ws_zone_notebooks_link" {
  name                  = "${azurerm_private_dns_zone.ws_zone_notebooks.name}_link_notebooks"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.ws_zone_notebooks.name
  virtual_network_id    = azurerm_virtual_network.aml_vnet.id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "ws_pe" {
  name                = "${var.local.machine_learning_workspace_name}-pe-${random_string.postfix.result}"
  location            = azurerm_resource_group.aml_rg.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml_subnet.id

  private_service_connection {
    name                           = "${var.local.machine_learning_workspace_name}-psc"
    private_connection_resource_id = azurerm_machine_learning_workspace.aml_ws.id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-ws"
    private_dns_zone_ids = [azurerm_private_dns_zone.ws_zone_api.id, azurerm_private_dns_zone.ws_zone_notebooks.id]
  }

  # Add Private Link after we configured the workspace 
  depends_on = [azurerm_machine_learning_compute_instance.moaur]
}

