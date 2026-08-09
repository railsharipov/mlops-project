variable "machine_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "subnet_region" {
  type = string
}

variable "ssh_key_metadata" {
  type = string
}

variable "tags" {
  type = list(string)
}
