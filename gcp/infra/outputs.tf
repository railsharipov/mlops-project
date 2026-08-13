output "vm_instance_private_dns" {
  value       = module.vm.instance_private_dns
  description = "The private DNS name of the VM instance."
}

output "database_instance_private_dns" {
  value       = module.postgres.database_instance_private_dns
  description = "The private DNS name of the database instance."
}

output "bucket_url" {
  value       = module.bucket.bucket_url
  description = "The URL of the bucket."
}
