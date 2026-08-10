output "instance_id" {
  value       = google_compute_instance.this.id
  description = "The ID of the VM instance."
}
