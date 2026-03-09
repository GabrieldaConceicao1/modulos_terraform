variable "bucket_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "public" {
  type    = bool
  default = false
}

locals {
  final_name = var.environment == "dev" ? "dev-${var.bucket_name}" : var.bucket_name
}

resource "aws_s3_bucket" "this" {
  bucket = local.final_name
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = !var.public
  block_public_policy     = !var.public
  ignore_public_acls      = !var.public
  restrict_public_buckets = !var.public
}

output "bucket_id" {
  value = aws_s3_bucket.this.id
}