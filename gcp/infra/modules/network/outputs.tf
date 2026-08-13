output "network_id" {
  value = google_compute_network.this.id
}

output "subnet_id" {
  value = google_compute_subnetwork.this.id
}

output "psc_endsubnet_id" {
  value = google_compute_subnetwork.psc_endpoint_range.id
}

output "subnet_region" {
  value = google_compute_subnetwork.this.region
}
