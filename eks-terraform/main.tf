provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

variable "cluster-name" {
  type    = "string"
  default = "austin-dev"
}

variable "ssh-public-key" {
  type    = "string"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAOOE5BD28gmqusNwFM65vYaAHvNxG5DMALL4imtC1dwx9huQOVoGdPdW5vp2gvu+j2bAhSYEimau3Cyq2jdY8kNpX+oAyiOEHDD5USJ2OMVGX1gc+Bn6TFIBstMUWMwc1Y0eV+qdrVZJllf+OdT2UDfdpFI5gaf+np6ZsW2RZg1nhgtbDRNLRvAgAQXn/yqxnrjGIRvmD+Ov/p/5A00BVfSeKwPTtjAkLIQfaJxusgm7Qd7w6H6jnhx6LM/uEph2HmcG8pzE94eYN5aJCy6ea7++zo/JR/6luq37Sdgl5I50I5FveFjclFqsJVQxs022j/cWSj6hkCZ+QE4qu4wVP"
}

provider "http" {}

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

# Override with variable or hardcoded value if necessary
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
  resources-name            = "k8s-${var.cluster-name}"
}
