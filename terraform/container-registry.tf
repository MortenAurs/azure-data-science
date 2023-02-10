resource "azurerm_container_registry" "this" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = false

  network_rule_set {
    default_action = "Deny"
    virtual_network {
      action    = "Allow"
      subnet_id = azurerm_subnet.aml.id
    }
  }
}

resource "azurerm_private_endpoint" "acr" {
  name                          = "pe-${var.container_registry_name}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "${var.container_registry_name}-nic-pe"
  private_service_connection {
    name                           = "${var.container_registry_name}-psc"
    private_connection_resource_id = azurerm_container_registry.this.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}
