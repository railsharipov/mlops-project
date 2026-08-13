output "instance_id" {
  value       = google_compute_instance.this.id
  description = "The ID of the VM instance."
}

output "instance_private_dns" {
  value       = google_dns_record_set.a.name
  description = "The name of the VM instance."
}
