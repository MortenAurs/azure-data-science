locals {
  base_name       = "azure-ml-poc"
  base_name_short = "azmlpocaml"

  vm_name                         = "vm-${local.base_name}"
  key_vault_name                  = "kv-${local.base_name}"
  machine_learning_workspace_name = "mlw-${base_name}"
  storage_account_name            = "st${local.base_name_short}"
  application_insights_name       = "ai-${local.base_name}"
  container_registry_name         = "acr${base_name_short}"
  virtual_network_name            = "vnet-${base_name}"
  subnet_name                     = "snet-${var.virtual_network_name}"
}

variable "resource_group_name" {
  default = "rg-ma-poc"
}

variable "location" {
  default = "northeurope"
}

variable "machine_learning_compute_instance_name" {
  default = "MOAURDSCI"
}

variable "vm_username" {
  default = "moaur"
}

