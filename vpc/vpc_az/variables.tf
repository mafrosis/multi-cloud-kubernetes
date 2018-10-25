variable "az" {
  description = "AWS availability zone"
}
variable "vpc_id" {
  description = "VPC ID in which to create subnets"
}
variable "vpc_internet_gateway_id" {
  description = "VPC internet gateway ID"
}
variable "network_name" {
  description = "Name prefix for AWS resources"
}
variable "public_cidr" {
  description = "CIDR for public subnet"
}
variable "private_cidr" {
  description = "CIDR for private subnet"
}
