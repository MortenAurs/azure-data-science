resource "azurerm_application_insights" "this" {
  name                = local.application_insights_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = "web"
}
