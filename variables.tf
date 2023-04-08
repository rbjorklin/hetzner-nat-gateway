variable "hcloud_token" {
  type     = string
  default  = null
  nullable = true
}

variable "ssh_key" {
  type     = string
  default  = null
  nullable = true
}

variable "network_name" {
  default = "example-net"
}
variable "wg_allowed_ips" {
  default     = "10.0.0.0/24"
  description = "Momma-separated list of IP addresses with CIDR masks from which incoming traffic for this peer is allowed"
}
variable "wg_endpoint" {
  default = "gateway.example.net"

}
variable "server_vpn_address" {
  default     = "10.0.0.1/24"
  description = "Address used by server on VPN"
}
variable "client_vpn_address" {
  default     = "10.0.0.2/24"
  description = "Address used by client on VPN"
}

variable "aws_r53_zone_id" {}
