Multi-cloud Kubernetes
-------------------

A vague effort at getting EKS up in a VPC with terraform, and peering that with a private GKE.


## AWSCLI Configuration



    [profile contino-sandbox]
    role_arn = arn:aws:iam::139908768132:role/OrganizationAccountAccessRole
    source_profile = contino-sts


## Using Google SSO for AWS

The project [aws-google-auth](github.com/cevoaustralia/aws-google-auth) configures command line
access to AWS accounts via the CLI.

    git clone https://github.com/cevoaustralia/aws-google-auth.git
    cd aws-google-auth
    docker build -t cevoaustralia/aws-google-auth .

Update the `Makefile` in the current directory with your Google SSO details.

Run `make login` to update your `~/.aws/config` and `~/.aws/credentials` with fresh auth data:

    make login


## Configure kubectl for EKS

After `terraform apply` has created all your AWS infra, the following `awscli` command will setup a
kubectl context and other plumbing for talking with EKS:

    AWS_PROFILE=contino-sandbox aws --region=us-west-2 eks update-kubeconfig --name multi
