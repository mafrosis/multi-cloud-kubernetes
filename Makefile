.PHONY: login

GOOGLE_USERNAME?=matt.black@contino.io
GOOGLE_IDP_ID?=C01dqpio3
GOOGLE_SP_ID?=339654134938

AWS_DEFAULT_REGION?=ap-southeast-2
AWS_PROFILE?=contino-sts
AWS_ROLE_ARN?=arn:aws:iam::443332089211:role/matt-black-account
DURATION?=28800

login:
	docker run -it --rm -v ~/.aws:/root/.aws cevoaustralia/aws-google-auth \
		-I ${GOOGLE_IDP_ID} \
		-S ${GOOGLE_SP_ID} \
		-u ${GOOGLE_USERNAME} \
		-R ${AWS_DEFAULT_REGION} \
		-p ${AWS_PROFILE} \
		-r ${AWS_ROLE_ARN} \
		-d ${DURATION}
