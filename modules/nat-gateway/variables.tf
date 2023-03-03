variable "hcloud_token" {
  type    = string
}

variable "ssh_keys" {
  type = list(string)
}

variable "labels" {
  type = map(string)
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
  default = "10.0.0.2"
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
