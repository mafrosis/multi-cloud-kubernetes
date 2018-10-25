output "az" {
  value = "${var.az}"
}
output "public_subnet_id" {
  value = "${aws_subnet.public.id}"
}
output "private_subnet_id" {
  value = "${aws_subnet.private.id}"
}
output "public_cidr" {
  value = "${var.public_cidr}"
}
output "private_cidr" {
  value = "${var.private_cidr}"
}
