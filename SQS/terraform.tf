variable "name" {}
variable "fifo" {}
variable "environment" {}

locals {
  final_name = "${var.environment}-${var.name}"
}

resource "aws_sqs_queue" "this" {
  name = var.fifo ? "${local.final_name}.fifo" : local.final_name

  fifo_queue = var.fifo

  content_based_deduplication = var.fifo ? true : null
}