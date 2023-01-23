variable "core_rg_name" {
  type        = string
  description = "Core resource group name"
}

variable "core_storage_name" {
  type        = string
  description = "Core storage account name"
}

variable "prefix" {
  type        = string
  description = "The prefix to apply to resource names (i.e. to differentiate organisations/projects)"
}

variable "environment" {
  type        = string
  description = "The environment to apply to resource names (to differentiate environments)"
}

variable "location" {
  type        = string
  description = "The location to deploy resources"
}

variable "tags" {
  type = map(any)
}
