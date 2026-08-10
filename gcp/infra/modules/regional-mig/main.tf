locals {
  name_prefix = trimspace(coalesce(var.name_prefix, ""))
}

resource "google_compute_instance_template" "this" {
  name_prefix  = var.name_prefix
  machine_type = var.machine_type

  disk {
    source_image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20260731"
    auto_delete  = true
    boot         = true

    disk_type    = "pd-balanced"
    disk_size_gb = 30
  }

  network_interface {
    subnetwork = var.subnetwork
    # No access_config: instances receive no public IPv4 address.
  }

  labels = var.common_labels

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "this" {
  name               = join("-", compact([local.name_prefix, "mig"]))
  region             = var.region
  base_instance_name = join("-", compact([local.name_prefix, "mig"]))
  target_size        = var.target_size

  version {
    instance_template = google_compute_instance_template.this.id
  }
}
