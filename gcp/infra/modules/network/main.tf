locals {
  name_prefix = trimspace(coalesce(var.name_prefix, ""))
}

resource "google_compute_network" "this" {
  name                    = join("-", compact([local.name_prefix, "net"]))
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = join("-", compact([local.name_prefix, "subnet"]))
  region        = var.region
  network       = google_compute_network.this.id
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_subnetwork" "psc_endpoint_range" {
  name          = join("-", compact([local.name_prefix, "psc-endpoint-range"]))
  region        = var.region
  network       = google_compute_network.this.id
  ip_cidr_range = "10.20.0.0/28"
}

resource "google_compute_firewall" "this" {
  name    = "test-firewall"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = [var.ssh_allow_ingress_tag]
}
