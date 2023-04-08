terraform {
  required_version = ">= 1.3.9"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.36.2"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_network" "network" {
  name     = var.network_name
  ip_range = var.network_cidr
}

#data "hcloud_network" "network" {
#  name     = var.network_name
#}

resource "hcloud_network_subnet" "subnet" {
  #network_id   = data.hcloud_network.network.id
  network_id   = hcloud_network.network.id
  type         = "server"
  network_zone = "us-east" # or "eu-central"
  #ip_range     = var.network_subnet_cidr
  ip_range = "10.0.0.0/24" # data.hcloud_network.network.ip_range
}

resource "hcloud_server_network" "srvnetwork" {
  server_id = hcloud_server.nat-gateway.id
  # https://github.com/hetznercloud/terraform-provider-hcloud/issues/356
  #subnet_id =  "${data.hcloud_network.network.id}-10.0.0.0/24"
  subnet_id = "${hcloud_network.network.id}-10.0.0.0/24"
  ip        = var.nat_gateway_ip
}

resource "hcloud_network_route" "default-gateway" {
  #network_id  = data.hcloud_network.network.id
  network_id  = hcloud_network.network.id
  destination = "0.0.0.0/0"
  gateway     = var.nat_gateway_ip
}

resource "hcloud_server" "nat-gateway" {
  name        = "nat-gateway"
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_keys
  labels      = var.labels
  # Can't have leading spaces with heredoc:
  # https://github.com/hetznercloud/terraform-provider-hcloud/issues/572
  user_data = <<EOT
#!/bin/bash
test -f /.cloud-init-complete && exit 0
dnf --assumeyes upgrade
dnf --assumeyes install nftables wireguard-tools neovim
alternatives --install /usr/bin/vim vim /usr/bin/nvim 1

rm -f /etc/sysctl.d/30-ipforward.conf

# Enable the kernel forwarding feature
for setting in net.ipv4.ip_forward=1 net.ipv6.conf.default.forwarding=1 net.ipv6.conf.all.forwarding=1 ; do
    echo "$${setting}" >> /etc/sysctl.d/30-ipforward.conf
    sysctl -w "$${setting}"
done

modprobe nf_tables
systemctl enable --now nftables

# The nftables commands below are equivalent to these iptables rules
#iptables --table nat --append POSTROUTING --source ${var.network_cidr} --out-interface eth0 --jump MASQUERADE
#iptables --append FORWARD --in-interface enp7s0 --out-interface eth0 --jump ACCEPT

# nftables getting started guide: https://www.linode.com/docs/guides/how-to-use-nftables/
# Create NAT table with masquerade for automatic source NAT
nft add table inet nat
nft add chain inet nat postrouting '{ type nat hook postrouting priority 100 ; }'
nft add rule inet nat postrouting oifname "eth0" ip saddr ${var.network_cidr} counter masquerade

# Set up forward rule
nft add table inet filter
nft add chain inet filter forward '{ type filter hook forward priority 0; policy drop; }'
nft add rule inet filter forward ct state related,established accept
nft add rule inet filter forward iifname enp7s0 oifname eth0 accept

# TODO: see CVE-2021-3773CVE-2021-3773 in /etc/nftables/nat.nft
# Save rules for later loading
nft list ruleset > /etc/nftables/hetzner-nat.nft

# Load rules after reboot
echo 'include "/etc/nftables/hetzner-nat.nft"' >> /etc/sysconfig/nftables.conf

# NAT Gateway needs this route
ip route add ${var.network_cidr} via ${var.gateway_ip}

mkdir -p /etc/wireguard
cat > /etc/wireguard/wg0.conf << EOF
[Interface]
PrivateKey = ${var.wg_server_private_key}
ListenPort = 51820
Address = ${var.server_vpn_address}

# Workstation
[Peer]
PublicKey = ${var.wg_client_public_key}

# Addresses with CIDR masks from which incoming traffic for this peer is allowed
AllowedIPs = ${var.wg_allowed_ips}
EOF

# Wireguard keys
echo ${var.wg_server_private_key} > /etc/wireguard/privatekey
echo ${var.wg_server_public_key} > /etc/wireguard/publickey

chmod 600 /etc/wireguard/wg0.conf
chmod 600 /etc/wireguard/privatekey
chmod 600 /etc/wireguard/publickey

systemctl enable --now wg-quick@wg0.service

# DNS config required for clients
# https://docs.hetzner.com/dns-console/dns/general/recursive-name-servers
mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/dns.conf << EOF
[Resolve]
DNS=185.12.64.2 185.12.64.1

touch /.cloud-init-complete
EOF
EOT
}
