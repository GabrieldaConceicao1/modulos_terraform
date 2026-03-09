############################
# AMBIENTE
############################
ENVIRONMENT = "dev"

################
# S3
################
AWS_S3            = false
AWS_BUCKET_NAME   = "s3_name"
AWS_POLICY_PUBLIC = false

################
# SQS
################
AWS_SQS      = false
AWS_SQS_NAME = "xxxxxxxxx"
AWS_SQS_FIFO = true

################
# RDS
################
AWS_RDS                = true
AWS_RDS_NAME           = "xxxxxx"
AWS_RDS_ENGINE         = "postgres"
AWS_RDS_TYPE           = "db.t3.micro"
AWS_RDS_ENGINE_VERSION = "16"
AWS_RDS_DISC           = 10
AWS_RDS_PUBLIC         = false
PUBLIC_SUBNET_GROUP    = ""
PRIVATE_SUBNET_GROUP   = "xxxxxx"
CREATE_PARAMETER_GROUP = true
PARAMETER_GROUP_NAME   = ""
VPC_ID                 = "xxxxx"