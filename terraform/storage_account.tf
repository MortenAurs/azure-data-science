# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Storage Account with VNET binding and Private Endpoint for Blob and File

resource "azurerm_storage_account" "aml_st" {
  name                     = local.storage_account_name
  location                 = var.location
  resource_group_name      = azurerm_resource_group.this.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Virtual Network & Firewall configuration

resource "azurerm_storage_account_network_rules" "firewall_rules" {
  storage_account_id = azurerm_storage_account.aml_st.id

  default_action             = "Deny"
  ip_rules                   = []
  virtual_network_subnet_ids = [azurerm_subnet.aml_subnet.id, azurerm_subnet.compute_subnet.id]
  bypass                     = ["AzureServices"]

  # Set network policies after Workspace has been created (will create File Share Datastore properly)
  depends_on = [azurerm_machine_learning_workspace.this]
}

# DNS Zones

resource "azurerm_private_dns_zone" "sa_zone_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone" "sa_zone_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_blob_link" {
  name                  = "${azurerm_private_dns_zone.sa_zone_blob}_link_blob"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_blob.name
  virtual_network_id    = azurerm_virtual_network.aml_vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "sa_zone_file_link" {
  name                  = "${azurerm_private_dns_zone.sa_zone_file}_link_file"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.sa_zone_file.name
  virtual_network_id    = azurerm_virtual_network.aml_vnet.id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "sa_pe_blob" {
  name                = "${local.storage_account_name}-st-pe-blob"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml_subnet.id

  private_service_connection {
    name                           = "${local.storage_account_name}-st-psc-blob"
    private_connection_resource_id = azurerm_storage_account.aml_st.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_zone_blob.id]
  }
}

resource "azurerm_private_endpoint" "sa_pe_file" {
  name                = "${local.storage_account_name}-st-pe-file"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = azurerm_subnet.aml_subnet.id

  private_service_connection {
    name                           = "${local.storage_account_name}-st-psc-file"
    private_connection_resource_id = azurerm_storage_account.aml_st.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-file"
    private_dns_zone_ids = [azurerm_private_dns_zone.sa_zone_file.id]
  }
}
