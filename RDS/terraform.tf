############################
# VARIABLES
############################

variable "name" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "storage" {
  type = number
}

variable "environment" {
  type = string
}

variable "public" {
  type = bool
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_group_name" {
  type = string
}

variable "private_subnet_group_name" {
  type = string
}
variable "parameter_group_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "create_parameter_group" {
  description = "Define se o parameter group será criado pelo Terraform"
  type        = bool
  default     = false
}

############################
# LOCALS
############################

locals {
  env_map = {
    dev        = "dev"
    staging    = "stg"
    production = ""
  }

  env_prefix = lookup(local.env_map, var.environment, var.environment)

  final_name = local.env_prefix != "" ? "${local.env_prefix}-${var.name}" : var.name

  deletion_protection = var.environment == "production"

  skip_snapshot = var.environment != "production"

  subnet_group_name = (
    var.public
    ? var.public_subnet_group_name
    : var.private_subnet_group_name
  )  

  allowed_cidrs = (
    var.environment == "production"
    ? ["10.188.0.0/16", "10.189.0.0/16"]
    : ["0.0.0.0/0"]
  )

  db_port = {
    postgres = 5432
    mysql    = 3306
    mariadb  = 3306
    aurora   = 3306
  }[var.engine]

  engine_major = split(".", var.engine_version)[0]
  family       = "${var.engine}${local.engine_major}"
}

############################
# RANDOM PASSWORD
############################

resource "random_password" "db" {
  length  = 16
  special = true
}

############################
# SECURITY GROUP
############################

resource "aws_security_group" "rds" {
  name   = "SG-${local.final_name}"
  vpc_id = var.vpc_id

  ingress {
    description = "DB access"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = local.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# PARAMETER GROUP
############################

resource "aws_db_parameter_group" "this" {

  count = var.create_parameter_group ? 1 : 0

  name   = "${local.final_name}-pg"
  family = local.family

  description = "Parameter group for ${local.final_name}"

  }


############################
# RDS INSTANCE
############################

resource "aws_db_instance" "this" {
  identifier              = local.final_name
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.storage

  username = var.db_username
  password = random_password.db.result

  db_subnet_group_name    = local.subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  parameter_group_name = var.create_parameter_group ? aws_db_parameter_group.this[0].name : var.parameter_group_name

  publicly_accessible     = var.public
  deletion_protection     = local.deletion_protection
  skip_final_snapshot     = local.skip_snapshot
  final_snapshot_identifier = local.skip_snapshot ? null : "${local.final_name}-final"

  availability_zone       = "us-east-1a"

  tags = {
    Name        = local.final_name
    Environment = var.environment
  }
}

############################
# OUTPUTS
############################

output "rds_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "rds_identifier" {
  value = aws_db_instance.this.id
}

output "rds_password" {
  value     = random_password.db.result
  sensitive = true
}