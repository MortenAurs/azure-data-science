resource "azurerm_machine_learning_workspace" "this" {
  name                          = local.machine_learning_workspace_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  application_insights_id       = azurerm_application_insights.this.id
  key_vault_id                  = azurerm_key_vault.this.id
  storage_account_id            = azurerm_storage_account.aml_st.id
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
  subnet_resource_id            = azurerm_subnet.aml_subnet.id
  description                   = "Azure ML to test while doing the AZ Data Science certification"
  identity {
    type = "SystemAssigned"
  }
  assign_to_user {
    object_id = "6e2aa9e5-8c05-4c2a-b166-157b32f6074c"
    tenant_id = "c317fa72-b393-44ea-a87c-ea272e8d963d"
  }
  depends_on = [
    azurerm_machine_learning_workspace.this
  ]
}

resource "azurerm_machine_learning_compute_cluster" "default" {
  name                          = "default-cluster"
  location                      = var.location
  vm_priority                   = "LowPriority"
  vm_size                       = "STANDARD_DS2_V2"
  machine_learning_workspace_id = azurerm_machine_learning_workspace.this.id
  subnet_resource_id            = azurerm_subnet.aml_subnet.id

  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 2
    scale_down_nodes_after_idle_duration = "PT120S" # 2 minutes
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
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
  name                          = "${local.machine_learning_workspace_name}-pe"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml_subnet.id
  custom_network_interface_name = "${local.machine_learning_workspace_name}-pe-nic"

  private_service_connection {
    name                           = "${local.machine_learning_workspace_name}-psc"
    private_connection_resource_id = azurerm_machine_learning_workspace.this.id
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

