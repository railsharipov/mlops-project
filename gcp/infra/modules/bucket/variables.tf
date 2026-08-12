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

variable "common_labels" {
  type     = map(string)
  default  = {}
  nullable = false
}
