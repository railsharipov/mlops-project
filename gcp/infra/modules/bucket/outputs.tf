output "bucket_id" {
  value       = google_storage_bucket.this.id
  description = "The ID of the bucket."
}

output "bucket_url" {
  value       = google_storage_bucket.this.url
  description = "The URL of the bucket."
}
