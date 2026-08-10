locals {
  name_prefix = trimspace(coalesce(var.name_prefix, ""))
}

resource "google_service_account" "this" {
  account_id   = join("-", compact([local.name_prefix, "vm"]))
  display_name = "VM A workload identity"
}

resource "google_secret_manager_secret_iam_member" "tailscale_secret_accessor" {
  project   = var.project_id
  secret_id = var.tailscale_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.this.email}"
}

resource "google_compute_instance" "this" {
  name         = join("-", compact([local.name_prefix, "vm"]))
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20260731"
      size  = 30
    }
  }

  network_interface {
    subnetwork = var.subnet_id

    access_config {
      # ephemeral public ip
    }
  }

  service_account {
    email  = google_service_account.this.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    "ssh-keys" = var.ssh_key_metadata
    "startup-script" = templatefile("${path.module}/scripts/startup.sh.tftpl", {
      project_id          = var.project_id
      tailscale_secret_id = var.tailscale_secret_id
    })
  }

  tags   = var.tags
  labels = var.common_labels

  depends_on = [
    google_secret_manager_secret_iam_member.tailscale_secret_accessor
  ]
}
