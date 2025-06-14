
resource "aws_sns_topic" "fanout_topic" {
  name = "${local.name}-topic"
}

resource "aws_sqs_queue" "queue" {
  name                        = var.is_fifo ? local.fifo_queue_name : local.name
  fifo_queue                  = var.is_fifo
  content_based_deduplication = var.is_fifo
  message_retention_seconds   = var.message_ttl

  tags = {
    Environment = var.env
    Namespace   = var.namespace
  }
}

resource "aws_sns_topic_subscription" "queue_subscription" {
  topic_arn = aws_sns_topic.fanout_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.queue.arn
}

data "aws_iam_policy_document" "queue_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.queue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.fanout_topic.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.queue.id
  policy    = data.aws_iam_policy_document.queue_policy.json
}