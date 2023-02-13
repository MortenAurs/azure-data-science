locals {
  base_name       = "azure-ml-poc"
  base_name_short = "azmlpocaml"

  vm_name                         = "vm-${local.base_name}"
  key_vault_name                  = "kv-${local.base_name}"
  machine_learning_workspace_name = "mlw-${local.base_name}"
  virtual_network_name            = "vnet-${local.base_name}"
  subnet_name                     = "snet-${local.virtual_network_name}"
  application_insights_name       = "ai-${local.base_name}"
  storage_account_name            = "st${local.base_name_short}"
  container_registry_name         = "acr${local.base_name_short}"

}

variable "resource_group_name" {
  default = "rg-ma-poc"
}

variable "location" {
  default = "northeurope"
}

variable "machine_learning_compute_instance_name" {
  default = "MOAURSTDCI"
}

variable "vm_username" {
  default = "moaur"
}

