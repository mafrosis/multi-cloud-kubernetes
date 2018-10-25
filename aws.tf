##################
# VPC

module "vpc" {
  source = "vpc"

  region              = "${var.aws-region}"
  network_name        = "${var.network_name}"
  bastion_private_key = "${var.bastion_private_key}"
  bastion_public_key  = "${var.bastion_public_key}"
}


##################
# IAM

resource "aws_iam_role" "cluster" {
  name = "cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.cluster.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.cluster.name}"
}


##################
# Security groups

resource "aws_security_group" "multi-cluster" {
  name        = "terraform-eks-multi-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    cidr_blocks = "${var.master-auth-networks}"
    description = "Master authenticated networks"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  /*ingress {
    description              = "Allow pods to communicate with the cluster API Server"
    from_port                = 443
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.multi-node.id}"
    to_port                  = 443
  }*/

  tags {
    Name = "terraform-eks-multi"
  }
}


##################
# EKS cluster

resource "aws_eks_cluster" "multi" {
  name     = "multi"
  role_arn = "${aws_iam_role.cluster.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.multi-cluster.id}"]

    subnet_ids = [
      "${module.vpc.az_a_public_subnet_id}",
      "${module.vpc.az_a_private_subnet_id}",
      "${module.vpc.az_b_public_subnet_id}",
      "${module.vpc.az_b_private_subnet_id}",
    ]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.AmazonEKSServicePolicy",
  ]
}


##################
# EKS worker node

resource "aws_iam_role" "multi-node" {
  name = "terraform-eks-multi-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = "${aws_iam_role.multi-node.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = "${aws_iam_role.multi-node.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = "${aws_iam_role.multi-node.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "multi-node" {
  name = "terraform-eks-multi"
  role = "${aws_iam_role.multi-node.name}"
}


resource "aws_security_group" "multi-node" {
  name        = "terraform-eks-multi-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  /*ingress {
    description              = "Allow nodes to communicate with each other"
    from_port                = 0
    protocol                 = "-1"
    source_security_group_id = "${aws_security_group.multi-node.id}"
    to_port                  = 65535
  }*/

  /*ingress {
    description              = "Cluster control plane to node/pod comms"
    from_port                = 1025
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.multi-cluster.id}"
    to_port                  = 65535
  }*/

  tags {
    Name = "terraform-eks-multi-node",

    "kubernetes.io/cluster/multi" = "owned",
  }
}

# Worker Node Security Group
resource "aws_security_group_rule" "multi-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.multi-node.id}"
  source_security_group_id = "${aws_security_group.multi-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

# Worker Node Security Group
resource "aws_security_group_rule" "multi-node-ingress-cluster" {
  description              = "Cluster control plane to node/pod comms"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.multi-node.id}"
  source_security_group_id = "${aws_security_group.multi-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

# Worker Node Access to EKS Master Cluster
resource "aws_security_group_rule" "multi-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.multi-cluster.id}"
  source_security_group_id = "${aws_security_group.multi-node.id}"
  to_port                  = 443
  type                     = "ingress"
}


data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  multi-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.multi.endpoint}' --b64-cluster-ca '${aws_eks_cluster.multi.certificate_authority.0.data}' multi
USERDATA
}

resource "aws_launch_configuration" "multi" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.multi-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.large"
  name_prefix                 = "terraform-eks-multi"
  security_groups             = ["${aws_security_group.multi-node.id}"]
  user_data_base64            = "${base64encode(local.multi-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "multi" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.multi.id}"
  max_size             = 2
  min_size             = 1
  name                 = "terraform-eks-multi"
  vpc_zone_identifier  = [
    "${module.vpc.az_a_private_subnet_id}",
    "${module.vpc.az_b_private_subnet_id}",
  ]

  tag {
    key                 = "Name"
    value               = "terraform-eks-multi"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/multi"
    value               = "owned"
    propagate_at_launch = true
  }
}

locals {
  config-map-aws-auth = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.multi-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF
}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}
