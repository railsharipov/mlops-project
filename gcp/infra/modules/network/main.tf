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

# resource "google_compute_firewall" "ssh_admin" {
#   name      = join("-", compact([local.name_prefix, "allow-ssh-admin"]))
#   network   = google_compute_network.this.name
#   direction = "INGRESS"
#   priority  = 1000

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   source_ranges = [var.ssh_allow_ingress_cidr]
#   target_tags   = [var.ssh_allow_ingress_tag]
# }
