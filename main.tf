data "external" "env" {
  program = ["${path.module}/env.sh"]
}

locals {
  hcloud_token = try(var.hcloud_token, data.external.env.result["HCLOUD_TOKEN"])
  ssh_key      = try(var.ssh_key, data.external.env.result["HCLOUD_SSH_KEY"])
}

module "nat-gateway" {
  source = "./modules/nat-gateway"

  hcloud_token = local.hcloud_token
  ssh_keys     = [local.ssh_key]

  labels = {
    deployment = terraform.workspace
  }
}
