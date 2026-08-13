output "bucket_name" {
  value       = google_storage_bucket.this.name
  description = "The name of the bucket."
}

output "bucket_url" {
  value       = google_storage_bucket.this.url
  description = "The URL of the bucket."
}
