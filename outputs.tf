output "status" {
  value = module.nat-gateway.status
}

output "datacenter" {
  value = module.nat-gateway.datacenter
}

output "public_ip" {
  value = module.nat-gateway.ip
}

output "client_wireguard_config" {
  value = <<EOT
[Interface]
PrivateKey = ${data.external.wireguard.result["WG_CLIENT_PRIVATE_KEY"]}
Address = ${var.client_vpn_address}

[Peer]
PublicKey = ${data.external.wireguard.result["WG_SERVER_PUBLIC_KEY"]}
#Endpoint = ${module.nat-gateway.ip}:51820
Endpoint = ${module.r53-dns-record.fqdn}:51820
AllowedIPs = ${var.wg_allowed_ips}
EOT
}
