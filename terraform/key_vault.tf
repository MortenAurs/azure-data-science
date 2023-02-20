# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Key Vault with VNET binding and Private Endpoint

resource "azurerm_key_vault" "this" {
  name                = "kv-${local.key_vault_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  network_acls {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = [azurerm_subnet.aml_subnet.id, azurerm_subnet.compute_subnet.id]
    bypass                     = "AzureServices"
  }
}

# DNS Zones

resource "azurerm_private_dns_zone" "kv_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

# Linking of DNS zones to Virtual Network

resource "azurerm_private_dns_zone_virtual_network_link" "kv_zone_link" {
  name                  = "${local.key_vault_name}_link_kv"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.kv_zone.name
  virtual_network_id    = azurerm_virtual_network.aml_vnet.id
}

# Private Endpoint configuration

resource "azurerm_private_endpoint" "kv_pe" {
  name                          = "${local.key_vault_name}-pe"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml_subnet.id
  custom_network_interface_name = "${local.key_vault_name}-pe-nic"

  private_service_connection {
    name                           = "${local.key_vault_name}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-kv"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_zone.id]
  }
}
