variable "name_prefix" {
  type     = string
  default  = ""
  nullable = false
}

variable "region" {
  type     = string
  nullable = false
}

variable "common_labels" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "dns_name" {
  type     = string
  nullable = false
}

variable "network_ids" {
  type     = list(string)
  nullable = false
}
