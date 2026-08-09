variable "project_id" {
  type        = string
  description = "GCP project ID"
  nullable = false
}

variable "region" {
  type        = string
  description = "Default GCP region"
  default     = "us-central1"
  nullable = false
}

variable "ssh_pubkey_file" {
  type = string
  nullable = false
}

variable "tailscale_secret_id" {
  type = string
  nullable = false
}
