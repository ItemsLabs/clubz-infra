output "arn" {
  value       = one(aws_iam_role.eks_node_role[*].arn)
  description = "ARN of the EKS node role."
}

output "id" {
  value       = one(aws_iam_role.eks_node_role[*].id)
  description = "ID of the EKS node role."
}

output "name" {
  value       = one(aws_iam_role.eks_node_role[*].name)
  description = "The name of the EKS node role."
}

output "create_date" {
  value       = one(aws_iam_role.eks_node_role[*].create_date)
  description = "Creation date of the EKS node role."
}

output "tags" {
  value       = one(aws_iam_role.eks_node_role[*].tags_all)
  description = <<EOT
    A map of tags assigned to the resource, including those
    inherited from the provider default_tags configuration block.
  EOT
}

output "unique_id" {
  value       = one(aws_iam_role.eks_node_role[*].unique_id)
  description = "Stable and unique string identifying the role."
}

output "aws_auth" {
  value       = local.aws_auth
  description = "Configuration block used in the aws-auth configmap for the role authorazation."
}

output "instance_profile_arn" {
  value       = one(aws_iam_instance_profile.profile[*].arn)
  description = "ARN assigned by AWS to the instance profile."
}

output "instance_profile_id" {
  value       = one(aws_iam_instance_profile.profile[*].id)
  description = "Instance profile's ID."
}
