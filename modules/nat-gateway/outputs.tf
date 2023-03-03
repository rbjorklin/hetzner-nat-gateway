output "status" {
  value = [hcloud_server.nat-gateway.status]
}

output "datacenter" {
  value = [hcloud_server.nat-gateway.datacenter]
}

output "ip" {
  value = hcloud_server.nat-gateway.ipv4_address
}
