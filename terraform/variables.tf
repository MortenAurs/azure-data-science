variable "resource_group_name" {
  default = "rg-data-science"
}
variable "location" {
  default = "northeurope"
}

variable "application_insights_name" {
  default = "ai-data-science"
}

variable "key_vault_name" {
  default = "kv-data-science-az"
}

variable "storage_account_name" {
  default = "stdsaml"
}

variable "machine_learning_workspace_name" {
  default = "mlw-data-science"
}

variable "machine_learning_compute_instance_name" {
  default = "MOAURDSCI"
}

variable "virtual_network_name" {
  default = "vnet-data-science"
}

locals {
  subnet_name = "snet-${var.virtual_network_name}"
}