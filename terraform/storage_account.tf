resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.aml.id]
  }
}

resource "azurerm_storage_account" "data_lake" {
  name                     = var.data_lake_name
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = "true"
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.aml.id]
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "this" {
  name               = "fs${var.data_lake_name}"
  storage_account_id = azurerm_storage_account.data_lake.id
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

