output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_route53_zone_id" {
  value = "${aws_route53_zone.vpc.zone_id}"
}

output "az_a_public_subnet_id" {
  value = "${module.az_a.public_subnet_id}"
}
output "az_a_private_subnet_id" {
  value = "${module.az_a.private_subnet_id}"
}
output "az_b_public_subnet_id" {
  value = "${module.az_b.public_subnet_id}"
}
output "az_b_private_subnet_id" {
  value = "${module.az_b.private_subnet_id}"
}

output "bastion_instance_id" {
  value = "${aws_instance.bastion.id}"
}

output "bastion_instance_role_id" {
  value = "${aws_iam_role.bastion_instance_role.name}"
}

output "bastion_security_group_id" {
  value = "${aws_security_group.bastion_sg.id}"
}

output "bastion_key_name" {
  value = "${aws_key_pair.bastion.key_name}"
}

output "bastion_hostname" {
  value = "${aws_eip.bastion_eip.public_ip}"
}
