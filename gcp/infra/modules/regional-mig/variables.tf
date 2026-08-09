variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "target_size" {
  type    = number
  default = 1
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}
