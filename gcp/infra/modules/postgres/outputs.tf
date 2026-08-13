output "database_instance_ip" {
  value       = google_sql_database_instance.this.private_ip_address
  description = "The private IP address of the database instance."
}

output "database_instance_private_dns" {
  value       = google_dns_record_set.cname.name
  description = "The private DNS name of the database instance."
}
