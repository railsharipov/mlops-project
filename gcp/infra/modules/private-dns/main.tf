locals {
  name_prefix = trimspace(coalesce(var.name_prefix, ""))
}

resource "google_dns_managed_zone" "this" {
  name       = join("-", compact([local.name_prefix, "zone"]))
  dns_name   = var.dns_name
  visibility = "private"

  private_visibility_config {
    dynamic "networks" {
      for_each = toset(var.network_ids)

      content {
        network_url = networks.value
      }
    }
  }
}
