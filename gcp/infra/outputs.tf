output "vm_instance_private_dns" {
  value       = module.vm.instance_private_dns
  description = "The private DNS name of the VM instance."
}

output "vm_instance_private_ip" {
  value       = module.vm.instance_private_ip
  description = "The private IP of the VM instance."
}

output "vm_instance_external_ip" {
  value       = module.vm.instance_external_ip
  description = "The external IP of the VM instance."
}

output "database_instance_private_dns" {
  value       = module.postgres.database_instance_private_dns
  description = "The private DNS name of the database instance."
}

output "bucket_url" {
  value       = module.bucket.bucket_url
  description = "The URL of the bucket."
}

output "subnet_cidr" {
  value       = module.net.subnet_cidr
  description = "The CIDR range of the subnet."
}
