resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  address_space       = ["10.10.0.0/22"]
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "aml" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.10.0.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}
