terraform {
  required_version = ">= 1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.62.0"
    }
  }
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_route53_record" "gateway" {
  zone_id = var.aws_r53_zone_id
  name    = "gateway"
  type    = "A"
  ttl     = "900"
  records = [var.ip]
}
