variable "name_prefix" {
  type     = string
  default  = ""
  nullable = false
}

variable "common_labels" {
  type     = map(string)
  default  = {}
  nullable = false
}
