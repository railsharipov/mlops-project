output "dns_name" {
  value = google_dns_managed_zone.this.dns_name
}

output "zone_name" {
  value = google_dns_managed_zone.this.name
}
