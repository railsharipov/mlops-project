locals {
  name_prefix = trimspace(coalesce(var.name_prefix, ""))
}

resource "google_storage_bucket" "this" {
  name          = join("-", compact([local.name_prefix, "bucket", var.project_id]))
  location      = upper(var.region)
  storage_class = "STANDARD"
  public_access_prevention = "enforced"
  force_destroy = true

  uniform_bucket_level_access = true
}
