output "topic_arn" {
  value = aws_sns_topic.fanout_topic.arn
}

output "queue_arn" {
  value = aws_sqs_queue.queue.arn
}