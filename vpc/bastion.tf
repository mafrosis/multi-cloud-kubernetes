# Bastion setup
#

# Bastion uses this role as its EC2 instance profile
resource "aws_iam_role" "bastion_instance_role" {
  name = "bastion_instance_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bastion" {
  name = "bastion-${var.network_name}"
  role = "${aws_iam_role.bastion_instance_role.name}"
}

data "aws_ami" "amzn" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

# Create bastion in public subnet of AZ a
resource "aws_instance" "bastion" {
  ami           = "${data.aws_ami.amzn.id}"
  instance_type = "t2.nano"
  key_name      = "${aws_key_pair.bastion.key_name}"
  subnet_id     = "${module.az_a.public_subnet_id}"

  iam_instance_profile        = "${aws_iam_instance_profile.bastion.id}"
  vpc_security_group_ids      = ["${aws_security_group.bastion_sg.id}"]
  associate_public_ip_address = true

	# don't recreate the bastion when the AMI changes
	# TODO make this optional?
	lifecycle {
    ignore_changes = ["ami"]
	}

  tags {
    Name = "${var.network_name}-bastion-tf"
    src  = "terraform"
    dep  = "digital"
    prd  = "${var.network_name}"
  }
}

resource "aws_eip" "bastion_eip" {
  vpc = true
}

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = "${aws_instance.bastion.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.network_name}-bastion-sg-tf"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    description = "outbound anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

	# TODO how to pass whitelist rules? define outside the module...
  ingress {
    description = "inbound from Matt Home"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["110.174.101.135/32"]
  }

  tags {
    src = "terraform"
    dep = "digital"
    prd = "${var.network_name}"
  }
}

# Deploy a new keypair to AWS
resource "aws_key_pair" "bastion" {
  key_name   = "${var.network_name}_bastion_key"
  public_key = "${var.bastion_public_key}"
}
