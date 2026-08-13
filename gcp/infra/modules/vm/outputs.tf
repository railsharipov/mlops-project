output "instance_id" {
  value       = google_compute_instance.this.id
  description = "The ID of the VM instance."
}

output "instance_private_dns" {
  value       = google_dns_record_set.a.name
  description = "The name of the VM instance."
}

output "instance_private_ip" {
  value       = google_compute_instance.this.network_interface.0.network_ip
  description = "The private IP of the VM instance."
}

output "instance_external_ip" {
  value       = google_compute_instance.this.network_interface.0.access_config.0.nat_ip
  description = "The external IP of the VM instance."
}
