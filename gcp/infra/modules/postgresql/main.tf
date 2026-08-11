locals {
  name_prefix = trimspace(coalesce(var.name_prefix, ""))
}

resource "google_sql_database_instance" "this" {
  name             = join("-", compact([local.name_prefix, "postgres"]))
  database_version = "POSTGRES_18"
  region           = var.region

  settings {
    # custom sandbox instance type
    edition = "ENTERPRISE"
    tier = "db-custom-2-8192"
    user_labels = var.common_labels
    availability_type = "ZONAL"
    disk_autoresize_limit = 100
  }
}
