Multi-cloud Kubernetes
-------------------

A vague effort at getting EKS up in a VPC with terraform, and peering that with a private GKE.


## Using Google SSO for AWS

The project [aws-google-auth](cevoaustralia/aws-google-auth) configures command line access to AWS accounts via the CLI.

    git clone https://github.com/cevoaustralia/aws-google-auth.git

Add the following `Makefile` to the directory:

    .PHONY: run

    GOOGLE_USERNAME?=matt.black@contino.io
    GOOGLE_IDP_ID?=
    GOOGLE_SP_ID?=

    AWS_DEFAULT_REGION?=ap-southeast-2
    AWS_PROFILE?=contino-sts
    AWS_ROLE_ARN?=arn:aws:iam::xxxxxxxx:role/matt-black-account
    DURATION?=28800

    run:
      docker run -it --rm -v ~/.aws:/root/.aws cevoaustralia/aws-google-auth \
        -I ${GOOGLE_IDP_ID} \
        -S ${GOOGLE_SP_ID} \
        -u ${GOOGLE_USERNAME} \
        -R ${AWS_DEFAULT_REGION} \
        -p ${AWS_PROFILE} \
        -r ${AWS_ROLE_ARN} \
        -d ${DURATION}

Run `make` to update your `~/.aws/config` and `~/.aws/credentials` with fresh auth data:

    make
