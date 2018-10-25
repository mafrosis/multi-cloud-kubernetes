###############################################

# Module for configuring single AZ in a VPC per AWS best practice
#
# Requires:
# - a VPC
# - an internet gateway
#
# Creates:
# - a public subnet
# - a private subnet
# - a nat gateway
# - routes
#
###############################################

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.public_cidr}"
  availability_zone = "${var.az}"

	# TODO how to pass arbitrary tags to module
  tags {
    Name   = "${var.network_name}-public-${var.az}-tf"
    src    = "terraform"
    public = "true"

	  "kubernetes.io/cluster/multi" = "shared"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  # Route outbound internet traffic through internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.vpc_internet_gateway_id}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}


##########################################

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.private_cidr}"
  availability_zone = "${var.az}"

  tags {
    Name    = "${var.network_name}-private-${var.az}-tf"
    src     = "terraform"
    private = "true"

		"kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"

  # Route outbound internet traffic through nat gateway
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.ngw.id}"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}


###############################################

# Create NAT gateway in public subnet
resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.ngw.id}"
  subnet_id     = "${aws_subnet.public.id}"
}

resource "aws_eip" "ngw" {
  vpc = true
}
