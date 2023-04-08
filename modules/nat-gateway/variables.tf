variable "hcloud_token" {
  type = string
}

variable "ssh_keys" {
  type = list(string)
}

variable "labels" {
  type = map(string)
}

variable "wg_server_private_key" {
  type = string
}

variable "wg_server_public_key" {
  type = string
}

variable "wg_client_private_key" {
  type = string
}

variable "wg_client_public_key" {
  type = string
}

variable "wg_allowed_ips" {
  type = string
}

variable "server_vpn_address" {
  description = "Address used by nat gateway on the VPN"
}

variable "client_vpn_address" {
  description = "Address used by the local client on the VPN"
}

variable "wg_endpoint" {
  type        = string
  description = "FQDN for the Wireguard server"
}

# Optionals

variable "network_name" {
  type    = string
  default = "rbjorklin-com"
}

variable "network_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "network_subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "gateway_ip" {
  type    = string
  default = "10.0.0.1"
}

variable "nat_gateway_ip" {
  type    = string
  default = "10.0.0.254"
}

variable "image" {
  type    = string
  default = "fedora-37"
}

variable "server_type" {
  type    = string
  default = "cpx11"
}

variable "location" {
  type    = string
  default = "ash"
}
