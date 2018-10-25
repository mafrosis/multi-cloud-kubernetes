variable "region" {
  default = "ap-southeast-2"
}

variable "network_name" {
  description = "Used to name VPC resources"
}

variable "bastion_public_key" {
  description = "Public key deployed on bastion"
}

variable "bastion_private_key" {
  description = "Path to SSH private key. Used to provision the bastion"
}
