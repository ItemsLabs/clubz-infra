locals {
  name = "${var.env}-${var.namespace}-${var.name}"

  fifo_queue_name = "${local.name}.fifo"
}