variable "aws-region" {
  type    = "string"
  default = "us-west-2"
}

variable "aws-rolearn" {
  type    = "string"
  default = "arn:aws:iam::139908768132:role/OrganizationAccountAccessRole"
}

variable "network_name" {
  type    = "string"
  default = "multi"
}

# TODO rename to filepath
variable "bastion_private_key" {
  type    = "string"
  default = "/Users/mafro/.ssh/multi.bastion.pky"
}

variable "bastion_public_key" {
  type    = "string"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCthKMjU1c3YltqPXaKkSJGmbUpVZQUB57ajuuJPBsiNNTDJjPq81KRmUkVYDVwgNRxyQGx6vQsE19I2Yyto+Gzg6NkCh4RC+XOI6YTyS8LRflmDAqdj/CYldMa5VvQhl9sjaXVZ3O5ZJnA54yPhdYL/2hkzfzANCDp3OBOS59I42xmaDmiWZe3qwZ4cHG+ZT00Ib7M7kcv7xxVzKZMVobK59ShrxXZws1QOhfrvOjfscSdLNWSmEaeAZ76HhqHas/GuKXEu3i5LqjjDOLEdBalkTx+AiJjUg2Dn4+aGnKcLjbl1i51Mf517z0usXIjwdPoyfERTwLGKeawmB5wDB4B mafro@takeshi.eggs"
}

variable "master-auth-networks" {
  type    = "list"
  default = [
    "110.174.101.135/32",
  ]
}
