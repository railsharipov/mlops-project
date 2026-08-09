resource "google_compute_network" "net_a" {
  name                    = "net-a"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_a" {
  name          = "subnet-a"
  region        = "us-central1"
  network       = google_compute_network.net_a.id
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_compute_firewall" "ssh_admin" {
  name      = "allow-ssh-admin"
  network   = google_compute_network.net_a.name
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.ssh_allow_ingress_cidr]
  target_tags   = [var.ssh_allow_ingress_tag]
}
