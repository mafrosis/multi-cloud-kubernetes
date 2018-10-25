# VPC & subnet configuration
#
# http://www.davidc.net/sites/default/subnets/subnets.html?network=10.0.0.0&mask=16&division=21.ff4010

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags {
    Name = "${var.network_name}-vpc-tf"
    src  = "terraform"
    prd  = "${var.network_name}"

	  "kubernetes.io/cluster/multi" = "shared"
  }
}

resource "aws_route53_zone" "vpc" {
  name   = "${var.network_name}.internal"
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

# Create public/private subnet in AZ "a"
module "az_a" {
  source = "vpc_az"

  az                      = "${var.region}a"
  network_name            = "${var.network_name}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  public_cidr             = "10.0.0.0/24"
  private_cidr            = "10.0.16.0/20"
  vpc_internet_gateway_id = "${aws_internet_gateway.igw.id}"
}

# Create public/private subnet in AZ "b"
module "az_b" {
  source = "vpc_az"

  az                      = "${var.region}b"
  network_name            = "${var.network_name}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  public_cidr             = "10.0.1.0/24"
  private_cidr            = "10.0.32.0/20"
  vpc_internet_gateway_id = "${aws_internet_gateway.igw.id}"
}
