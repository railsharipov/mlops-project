data "http" "my_public_ip" {
  url = "https://api.ipify.org"

  request_headers = {
    Accept = "text/plain"
  }
}

locals {
  ssh_user = "gcp_vm"
  ssh_admin_tag = "ssh-admin"
  my_public_ip = chomp(data.http.my_public_ip.response_body)
  my_public_cidr = "${local.my_public_ip}/32"
}

module "net1" {
  source = "./modules/network"
  ssh_allow_ingress_cidr = local.my_public_cidr
  ssh_allow_ingress_tag = local.ssh_admin_tag
}

module "vm1" {
  source = "./modules/vm"
  machine_type = "e2-standard-4"
  subnet_id = module.net1.subnet_a_id
  subnet_region = module.net1.subnet_a_region
  ssh_key_metadata = "${local.ssh_user}:${file(var.ssh_pubkey_file)}"
  tags = [local.ssh_admin_tag]
}

# module "mig1" {
#   source = "./modules/regional-mig"
#   name       = "mig1"
#   region     = module.net1.subnet_a_region
#   subnetwork = module.net1.subnet_a_id
#   machine_type = "e2-standard-4"
#   target_size = 1
# }
