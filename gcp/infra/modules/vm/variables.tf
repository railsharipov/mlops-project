variable "project_id" {
  type     = string
  nullable = false
}

variable "name_prefix" {
  type     = string
  default  = ""
  nullable = false
}

variable "zone" {
  type     = string
  nullable = false
}

variable "common_labels" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "machine_type" {
  type     = string
  nullable = false
}

variable "subnet_id" {
  type     = string
  nullable = false
}

variable "subnet_region" {
  type     = string
  nullable = false
}

variable "tailscale_secret_id" {
  type     = string
  nullable = false
}

variable "ssh_key_metadata" {
  type     = string
  nullable = false
}

variable "tags" {
  type     = list(string)
  default  = []
  nullable = false
}
