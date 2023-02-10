locals {
  base_name       = "azure-ml-poc"
  base_name_short = "azmlpocaml"
}

variable "resource_group_name" {
  default = "rg-ma-poc"
}

variable "location" {
  default = "northeurope"
}

variable "application_insights_name" {
  default = "ai-${base_name}"
}

variable "vm_name" {
  default = "vm-${base_name}"
}
variable "key_vault_name" {
  default = "kv-${base_name}"
}

variable "storage_account_name" {
  default = "st${base_name_short}"
}

variable "data_lake_name" {
  default = "dl${base_name_short}"
}

variable "container_registry_name" {
  default = "acr${base_name_short}"
}

variable "machine_learning_workspace_name" {
  default = "mlw-${base_name}"
}

variable "machine_learning_compute_instance_name" {
  default = "MOAURDSCI"
}

variable "virtual_network_name" {
  default = "vnet-${base_name}"
}

locals {
  subnet_name = "snet-${var.virtual_network_name}"
}

variable "vm_username" {
  default = "moaur"
}

resource "random_string" "postfix" {
  length  = 6
  special = false
  upper   = false
}
