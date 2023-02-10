resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  location                 = var.location
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
  location                 = var.location
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
  name                          = "${var.storage_account_name}-pe-blob"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "${var.storage_account_name}-nic-pe-blob"
  private_service_connection {
    name                           = "${var.storage_account_name}-psc-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_private_endpoint" "file" {
  name                          = "${var.storage_account_name}-pe-file"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "${var.storage_account_name}-nic-pe-file"
  private_service_connection {
    name                           = "${var.storage_account_name}-psc-file"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
}

resource "azurerm_private_endpoint" "table" {
  name                          = "${var.storage_account_name}-pe-table"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  subnet_id                     = azurerm_subnet.aml.id
  custom_network_interface_name = "${var.storage_account_name}-nic-pe-table"
  private_service_connection {
    name                           = "${var.storage_account_name}-psc-table"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }
}

