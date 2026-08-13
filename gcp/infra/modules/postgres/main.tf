locals {
  name_prefix = trimspace(coalesce(var.name_prefix, ""))

  # a little hacky but works
  cloud_sql_psc_dns_name = one([
    for dns in google_sql_database_instance.this.dns_names : dns.name
    if dns.connection_type == "PRIVATE_SERVICE_CONNECT" &&
      dns.dns_scope == "INSTANCE" && dns.name != google_sql_database_instance.this.dns_name
  ])
}

data "google_secret_manager_secret_version" "pg_password" {
  project = var.project_id
  secret  = var.pgpassword_secret_id
  version = tostring(var.pgpassword_secret_version)
}

resource "google_sql_database_instance" "this" {
  name                = join("-", compact([local.name_prefix, "postgres"]))
  database_version    = "POSTGRES_18"
  region              = var.region
  deletion_protection = false

  depends_on = [
    google_network_connectivity_service_connection_policy.this
  ]

  settings {
    # custom sandbox instance type
    edition               = "ENTERPRISE"
    tier                  = "db-custom-2-8192"
    user_labels           = var.common_labels
    availability_type     = "ZONAL"
    disk_autoresize_limit = 100

    ip_configuration {
      ipv4_enabled = false

      psc_config {
        psc_enabled          = true
        psc_auto_dns_enabled = true

        allowed_consumer_projects = [
          var.project_id
        ]

        psc_auto_connections {
          consumer_network            = var.network_id
          consumer_service_project_id = var.project_id
        }
      }
    }
  }
}

resource "google_sql_user" "this" {
  name                = var.username
  instance            = google_sql_database_instance.this.name
  password_wo         = data.google_secret_manager_secret_version.pg_password.secret_data
  password_wo_version = data.google_secret_manager_secret_version.pg_password.version
}

resource "google_sql_database" "this" {
  name     = var.database_name
  instance = google_sql_database_instance.this.name
}

resource "google_dns_record_set" "cname" {
  name         = "postgres.${var.private_dns_name}"
  managed_zone = var.private_dns_zone_name
  type         = "CNAME"

  rrdatas = [
    "${local.cloud_sql_psc_dns_name}."
  ]
}

resource "google_network_connectivity_service_connection_policy" "this" {
  name          = join("-", compact([local.name_prefix, "connectivity-policy"]))
  description   = "Cloud SQL service connection policy"
  location      = var.region
  service_class = "google-cloud-sql"
  network       = var.network_id
  psc_config {
    subnetworks = [var.pcs_endpoint_subnet_id]
    limit       = 2
  }
}

# resource "google_compute_global_address" "this" {
#   name          = join("-", compact([local.name_prefix, "private-services-range"]))
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 24
#   network       = var.network_id
# }

# resource "google_service_networking_connection" "this" {
#   network = var.network_id
#   service = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [
#     google_compute_global_address.this.name
#   ]
# }
