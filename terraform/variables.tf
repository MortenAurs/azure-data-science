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

variable "data_lake_name" {
  default = "dldsaml"
}

variable "container_registry_name" {
  default = "acrdsdp100"
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

variable "deploy_aks" {
  default = false
}

variable "jumphost_username" {
  default = "moaur"
}

resource "random_string" "postfix" {
  length  = 6
  special = false
  upper   = false
}

variable "location" {
  default = "North Europe"
}
