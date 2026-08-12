output "database_instance_ip" {
  value       = google_sql_database_instance.this.private_ip_address
  description = "The private IP address of the database instance."
}
