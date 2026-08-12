locals {
  name_prefix = trimspace(coalesce(var.name_prefix, ""))
}

resource "google_sql_database_instance" "this" {
  name             = join("-", compact([local.name_prefix, "postgres"]))
  database_version = "POSTGRES_18"
  region           = var.region

  depends_on = [google_service_networking_connection.this]

  settings {
    # custom sandbox instance type
    edition               = "ENTERPRISE"
    tier                  = "db-custom-2-8192"
    user_labels           = var.common_labels
    availability_type     = "ZONAL"
    disk_autoresize_limit = 100

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }
  }
}

resource "google_sql_user" "this" {
  name                = var.username
  instance            = google_sql_database_instance.this.name
  password_wo         = var.password
  password_wo_version = var.password_version
}

resource "google_sql_database" "this" {
  name     = var.database_name
  instance = google_sql_database_instance.this.name
}

resource "google_compute_global_address" "this" {
  name          = join("-", compact([local.name_prefix, "private-services-range"]))
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = var.network_id
}

resource "google_service_networking_connection" "this" {
  network = var.network_id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.this.name
  ]
}
