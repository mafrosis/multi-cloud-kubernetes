VPC Availability Zone Module
=====================================

Module for configuring single AZ in a VPC per AWS best practice


Requirements
-------------------------------------

 - a [VPC](../jenkins/vpc.tf#L6)
 - an [internet gateway](../jenkins/vpc.tf#L20)


Using this Module
-------------------------------------

An example usage from the [Jenkins](../jenkins) configuration:


    module "az_a" {
      source = "../vpc_az"
        
      az                      = "${var.region}a"
      network_name            = "${var.network_name}"
      vpc_id                  = "${aws_vpc.vpc.id}"
      public_cidr             = "10.1.1.0/24"
      private_cidr            = "10.1.2.0/24"
      vpc_internet_gateway_id = "${aws_internet_gateway.igw.id}"
    }
