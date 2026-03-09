terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

########################
# VARIÁVEIS
########################

variable "ENVIRONMENT" {}
variable "AWS_S3" { type = bool }
variable "AWS_BUCKET_NAME" {}
variable "AWS_POLICY_PUBLIC" { type = bool }

variable "AWS_SQS" { type = bool }
variable "AWS_SQS_NAME" {}
variable "AWS_SQS_FIFO" { type = bool }

variable "AWS_RDS" { type = bool }
variable "AWS_RDS_NAME" {}
variable "AWS_RDS_ENGINE" {}
variable "AWS_RDS_TYPE" {}
variable "AWS_RDS_DISC" { type = number }
variable "AWS_RDS_PUBLIC" { type = bool }

########################
# VARIABLES
########################

variable "VPC_ID" {
  type = string
}
variable "AWS_RDS_ENGINE_VERSION" {
  type = string
}

variable "PUBLIC_SUBNET_GROUP" {
  type = string
}

variable "PRIVATE_SUBNET_GROUP" {
  type = string
}

variable "PARAMETER_GROUP_NAME" {
  type = string
}
variable "db_username" {
  description = "Username do banco RDS"
  type        = string
}
variable "CREATE_PARAMETER_GROUP" {
  description = "Define se o parameter group será criado pelo Terraform"
  type        = bool
  default     = false
}
variable "parameter_group_name" {
  type    = string
  default = null
}
output "rds_password" {
  value     = module.rds[0].rds_password
  sensitive = true
}
########################
# MODULE S3
########################

module "s3" {
  source = "./S3"

  count = var.AWS_S3 ? 1 : 0

  bucket_name = var.AWS_BUCKET_NAME
  environment = var.ENVIRONMENT
  public      = var.AWS_POLICY_PUBLIC
}

########################
# MODULE SQS
########################

module "sqs" {
  source = "./SQS"

  count = var.AWS_SQS ? 1 : 0

  name        = var.AWS_SQS_NAME
  fifo        = var.AWS_SQS_FIFO
  environment = var.ENVIRONMENT
}

########################
# MODULE RDS
########################

module "rds" {
  source = "./RDS"
  count  = var.AWS_RDS ? 1 : 0


  name                      = var.AWS_RDS_NAME
  db_username               = var.db_username
  engine                    = var.AWS_RDS_ENGINE
  engine_version            = var.AWS_RDS_ENGINE_VERSION
  instance_class            = var.AWS_RDS_TYPE
  storage                   = var.AWS_RDS_DISC
  environment               = var.ENVIRONMENT
  public                    = var.AWS_RDS_PUBLIC
  vpc_id                    = var.VPC_ID
  public_subnet_group_name  = var.PUBLIC_SUBNET_GROUP
  private_subnet_group_name = var.PRIVATE_SUBNET_GROUP
  parameter_group_name      = var.PARAMETER_GROUP_NAME
  create_parameter_group    = var.CREATE_PARAMETER_GROUP
}