variable "naming_prefix" {
  type        = string
  description = "Prefix used to name resources"
}

variable "truncated_naming_prefix" {
  type        = string
  description = "Truncated (max 20 chars, no hyphens etc.) prefix to name e.g storage accounts"
}

variable "location" {
  type        = string
  description = "The location to deploy resources"
}

variable "tags" {
  type = map(any)
}
