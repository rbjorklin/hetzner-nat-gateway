data "external" "env" {
  program = ["${path.module}/datasource/env.sh"]
}

data "external" "wireguard" {
  program = ["${path.module}/datasource/wireguard.sh"]
}

locals {
  hcloud_token = var.hcloud_token != null ? var.hcloud_token : data.external.env.result["HCLOUD_TOKEN"]
  ssh_key      = var.ssh_key != null ? var.ssh_key : data.external.env.result["HCLOUD_SSH_KEY"]
}

module "nat-gateway" {
  source = "./modules/nat-gateway"

  hcloud_token          = local.hcloud_token
  ssh_keys              = [local.ssh_key]
  wg_server_private_key = data.external.wireguard.result["WG_SERVER_PRIVATE_KEY"]
  wg_server_public_key  = data.external.wireguard.result["WG_SERVER_PUBLIC_KEY"]
  wg_client_private_key = data.external.wireguard.result["WG_CLIENT_PRIVATE_KEY"]
  wg_client_public_key  = data.external.wireguard.result["WG_CLIENT_PUBLIC_KEY"]
  wg_endpoint           = var.wg_endpoint
  wg_allowed_ips        = var.wg_allowed_ips
  server_vpn_address    = var.server_vpn_address
  client_vpn_address    = var.client_vpn_address

  labels = {
    deployment = terraform.workspace
  }
}

module "r53-dns-record" {
  source = "./modules/route53"

  access_key      = data.external.env.result["AWS_ACCESS_KEY_ID"]
  secret_key      = data.external.env.result["AWS_SECRET_ACCESS_KEY"]
  ip              = module.nat-gateway.ip
  aws_r53_zone_id = var.aws_r53_zone_id
}
