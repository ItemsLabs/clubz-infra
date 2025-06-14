output "arn" {
  value       = one(aws_launch_template.lt[*].arn)
  description = "ARN of the launch template."
}

output "id" {
  value       = one(aws_launch_template.lt[*].id)
  description = "ID of the launch template."
}

output "latest_version" {
  value       = one(aws_launch_template.lt[*].latest_version)
  description = "The latest version of the launch template."
}

output "tags" {
  value       = one(aws_launch_template.lt[*].tags_all)
  description = <<EOT
    A map of tags assigned to the resource, including those
    inherited from the provider default_tags configuration block.
  EOT
}
