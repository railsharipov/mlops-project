resource "google_compute_instance" "vm_a" {
  name         = "vm-a"
  machine_type = var.machine_type
  zone = "${var.subnet_region}-a"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20260731"
    }
  }

  network_interface {
    subnetwork = var.subnet_id

    access_config {
      # Ephemeral public IPv4
    }
  }

  metadata = {
    "ssh-keys" = var.ssh_key_metadata
    "startup-script" = file("${path.module}/scripts/startup.sh")
  }

  tags = var.tags
}
