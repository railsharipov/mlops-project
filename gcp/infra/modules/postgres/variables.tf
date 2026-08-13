variable "name_prefix" {
  type     = string
  default  = ""
  nullable = false
}

variable "project_id" {
  type     = string
  nullable = false
}

variable "region" {
  type     = string
  nullable = false
}

variable "network_id" {
  type     = string
  nullable = false
}

variable "pcs_endpoint_subnet_id" {
  default  = "Subnet for Cloud SQL PSC endoints"
  type     = string
  nullable = false
}

variable "common_labels" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "database_name" {
  type     = string
  nullable = false
}

variable "username" {
  type     = string
  nullable = false
}

variable "pgpassword_secret_id" {
  type     = string
  nullable = false
}

variable "pgpassword_secret_version" {
  type     = number
  nullable = false
}

variable "private_dns_name" {
  type     = string
  nullable = false
}

variable "private_dns_zone_name" {
  type     = string
  nullable = false
}
