variable "project_id" {
  type        = string
  description = "GCP project ID"
  nullable    = false
}

variable "region" {
  type        = string
  description = "Default GCP region"
  default     = "us-central1"
  nullable    = false
}

variable "ssh_pubkey_file" {
  type     = string
  nullable = false
}

variable "tailscale_auth_key_secret_id" {
  type     = string
  default = "tailscale-auth-key"
  nullable = false
}

variable "jupyter_token_secret_id" {
  type     = string
  default  = "jupyter-token"
  nullable = false
}

variable "pgpassword_secret_id" {
  type     = string
  default  = "postgres-password"
  nullable = false
}

variable "tailnet_domain" {
  type     = string
  nullable = false
}
