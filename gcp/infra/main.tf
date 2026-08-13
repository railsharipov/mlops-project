data "http" "my_public_ip" {
  url = "https://api.ipify.org"

  request_headers = {
    Accept = "text/plain"
  }
}

locals {
  name_prefix      = "mlops"
  region           = "us-east1"
  zone             = "us-east1-b"
  ssh_user         = local.name_prefix
  ssh_admin_tag    = "ssh-admin"
  private_dns_name = "internal.${local.name_prefix}.net."
  my_public_ip     = chomp(data.http.my_public_ip.response_body)
  my_public_cidr   = "${local.my_public_ip}/32"

  common_labels = {
    environment = "dev"
    group       = local.name_prefix
    managed_by  = "opentofu"
  }
}

module "net" {
  source                 = "./modules/network"
  name_prefix            = local.name_prefix
  region                 = local.region
  ssh_allow_ingress_cidr = local.my_public_cidr
  ssh_allow_ingress_tag  = local.ssh_admin_tag
  common_labels          = local.common_labels
}

module "private_dns" {
  source        = "./modules/private-dns"
  name_prefix   = local.name_prefix
  region        = local.region
  dns_name      = local.private_dns_name
  network_ids   = [module.net.network_id]
  common_labels = local.common_labels
}

module "vm" {
  source                  = "./modules/vm"
  project_id              = var.project_id
  name_prefix             = local.name_prefix
  zone                    = local.zone
  machine_type            = "e2-standard-4"
  subnet_id               = module.net.subnet_id
  subnet_region           = module.net.subnet_region
  bucket_name             = module.bucket.bucket_name
  tailscale_secret_id     = var.tailscale_auth_key_secret_id
  jupyter_token_secret_id = var.jupyter_token_secret_id
  pgpassword_secret_id    = var.pgpassword_secret_id
  ssh_user                = local.ssh_user
  ssh_public_key          = trimspace(file(var.ssh_pubkey_file))
  tags                    = [local.ssh_admin_tag]
  common_labels           = local.common_labels
  tailnet_domain          = var.tailnet_domain
  private_dns_zone_name   = module.private_dns.zone_name
  private_domain          = module.private_dns.domain
}

module "postgres" {
  source                 = "./modules/postgres"
  name_prefix            = local.name_prefix
  project_id             = var.project_id
  region                 = local.region
  network_id             = module.net.network_id
  pcs_endpoint_subnet_id = module.net.psc_endpoint_subnet_id
  common_labels          = local.common_labels
  database_name          = local.name_prefix
  username               = local.name_prefix
  pgpassword_secret_id   = var.pgpassword_secret_id
  pgpassword_secret_version = 2
  private_dns_zone_name  = module.private_dns.zone_name
  private_domain       = module.private_dns.domain
}

module "bucket" {
  source        = "./modules/bucket"
  name_prefix   = local.name_prefix
  project_id    = var.project_id
  region        = local.region
  common_labels = local.common_labels
}
