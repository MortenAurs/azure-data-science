# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# Virtual Network definition

resource "azurerm_virtual_network" "aml_vnet" {
  name                = "${local.virtual_network_name}-vnet-"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "aml_subnet" {
  name                                           = "${local.virtual_network_name}-aml-subnet"
  resource_group_name                            = azurerm_resource_group.this.name
  virtual_network_name                           = azurerm_virtual_network.aml_vnet.name
  address_prefixes                               = ["10.0.1.0/24"]
  service_endpoints                              = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "compute_subnet" {
  name                                           = "${local.virtual_network_name}-compute-subnet"
  resource_group_name                            = azurerm_resource_group.this.name
  virtual_network_name                           = azurerm_virtual_network.aml_vnet.name
  address_prefixes                               = ["10.0.2.0/24"]
  service_endpoints                              = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage"]
  enforce_private_link_service_network_policies  = false
  enforce_private_link_endpoint_network_policies = false
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.aml_vnet.name
  address_prefixes     = ["10.0.10.0/27"]
}
