output "arn" {
  value       = one(aws_security_group.node_sg[*].arn)
  description = "ARN of the nodes security group."
}

output "id" {
  value       = one(aws_security_group.node_sg[*].id)
  description = "ID of the nodes security group."
}

output "owner_id" {
  value       = one(aws_security_group.node_sg[*].owner_id)
  description = "Account ID of the nodes security group."
}

output "tags" {
  value       = one(aws_security_group.node_sg[*].tags_all)
  description = <<EOT
    A map of tags assigned to the resource, including those
    inherited from the provider default_tags configuration block.
  EOT
}
