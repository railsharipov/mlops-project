variable "name_prefix" {
  type     = string
  default  = ""
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

variable "password" {
  type     = string
  nullable = false
}

variable "password_version" {
  type     = number
  nullable = false
}
