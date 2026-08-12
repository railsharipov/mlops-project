data "http" "my_public_ip" {
  url = "https://api.ipify.org"

  request_headers = {
    Accept = "text/plain"
  }
}

locals {
  name_prefix = "mlops"

  region = "us-east1"
  zone   = "us-east1-b"

  ssh_user      = local.name_prefix
  ssh_admin_tag = "ssh-admin"

  my_public_ip   = chomp(data.http.my_public_ip.response_body)
  my_public_cidr = "${local.my_public_ip}/32"

  common_labels = {
    environment = "dev"
    group       = local.name_prefix
    managed_by  = "opentofu"
  }
}

data "google_secret_manager_secret" "tailscale_auth_key" {
  project   = var.project_id
  secret_id = var.tailscale_secret_id
}

module "net" {
  source                 = "./modules/network"
  name_prefix            = local.name_prefix
  region                 = local.region
  ssh_allow_ingress_cidr = local.my_public_cidr
  ssh_allow_ingress_tag  = local.ssh_admin_tag
  common_labels          = local.common_labels
}

module "vm" {
  source              = "./modules/vm"
  project_id          = var.project_id
  name_prefix         = local.name_prefix
  zone                = local.zone
  machine_type        = "e2-standard-4"
  subnet_id           = module.net.subnet_id
  subnet_region       = module.net.subnet_region
  tailscale_secret_id = data.google_secret_manager_secret.tailscale_auth_key.secret_id
  ssh_key_metadata    = "${local.ssh_user}:${file(var.ssh_pubkey_file)}"
  tags                = [local.ssh_admin_tag]
  common_labels       = local.common_labels
}

module "postgres" {
  source           = "./modules/postgres"
  name_prefix      = local.name_prefix
  region           = local.region
  network_id       = module.net.network_id
  common_labels    = local.common_labels
  database_name    = local.name_prefix
  username         = local.name_prefix
  password         = var.db_password
  password_version = var.db_password_version
}

module "bucket" {
  source      = "./modules/bucket"
  name_prefix = local.name_prefix
  project_id  = var.project_id
  region      = local.region
  common_labels = local.common_labels
}
