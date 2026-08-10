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

variable "ssh_allow_ingress_cidr" {
  type     = string
  nullable = false
}

variable "ssh_allow_ingress_tag" {
  type     = string
  nullable = false
}
