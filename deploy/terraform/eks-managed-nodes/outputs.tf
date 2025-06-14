output "arn" {
  value       = one(aws_eks_node_group.managed_nodes[*].arn)
  description = "ARN of the EKS managed node group."
}

output "id" {
  value       = one(aws_eks_node_group.managed_nodes[*].id)
  description = "EKS Cluster name and EKS Node Group name separated by a colon."
}

output "role_arn" {
  value       = var.node_role_arn
  description = "ARN of the IAM role that provides permissions for the EKS nodes."
}

output "asg_name" {
  value       = one(aws_eks_node_group.managed_nodes[*].resources[0].autoscaling_groups[0].name)
  description = "Name of the AutoScaling Group."
}

output "default_lt" {
  value       = one(module.default_lt[*])
  description = "A map with the default launch templatee parameters"
}

output "default_security_group_id" {
  value       = one(module.default_sg[*].id)
  description = "ID of the default security group."
}

output "remote_access_security_group_id" {
  value       = one(aws_eks_node_group.managed_nodes[*].resources[0].remote_access_security_group_id)
  description = "Identifier of the remote access EC2 Security Group."
}

output "tags" {
  value       = one(aws_eks_node_group.managed_nodes[*].tags_all)
  description = <<EOT
    A map of tags assigned to the resource, including those
    inherited from the provider default_tags configuration block.
  EOT
}

output "status" {
  value       = one(aws_eks_node_group.managed_nodes[*].status)
  description = "Status of the EKS managed node group."
}
