variable "name_prefix" {
  type = string
  default = ""
  nullable = false
}

variable "common_labels" {
  type = map(string)
  default = {}
  nullable = false
}

variable "region" {
  type = string
  nullable = false
}

variable "subnetwork" {
  type = string
  nullable = false
}

variable "target_size" {
  type    = number
  default = 1
  nullable = false
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
  nullable = false
}
