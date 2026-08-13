variable "project_id" {
  type     = string
  nullable = false
}

variable "name_prefix" {
  type     = string
  default  = ""
  nullable = false
}

variable "zone" {
  type     = string
  nullable = false
}

variable "common_labels" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "machine_type" {
  type     = string
  nullable = false
}

variable "subnet_id" {
  type     = string
  nullable = false
}

variable "subnet_region" {
  type     = string
  nullable = false
}

variable "bucket_name" {
  type     = string
  nullable = false
}

variable "tailscale_secret_id" {
  type     = string
  nullable = false
}

variable "pgpassword_secret_id" {
  type        = string
  nullable    = false
  description = "Secret Manager secret ID for the PostgreSQL password used by MLflow."
}

variable "jupyter_token_secret_id" {
  type        = string
  nullable    = false
  description = "Secret Manager secret ID for the JupyterLab authentication token."
}

variable "ssh_user" {
  type        = string
  nullable    = false
  description = "SSH username; also used as the Linux user running the systemd services."
}

variable "ssh_public_key" {
  type        = string
  nullable    = false
  description = "SSH public key content (without trailing newline)."
}

variable "tags" {
  type     = list(string)
  default  = []
  nullable = false
}

variable "tailnet_domain" {
  type     = string
  nullable = false
}

variable "private_domain" {
  type     = string
  nullable = false
}

variable "private_dns_zone_name" {
  type     = string
  nullable = false
}
