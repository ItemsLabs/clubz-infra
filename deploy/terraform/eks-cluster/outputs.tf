output "cluster_id" {
  description = "The name/id of the EKS cluster."
  value       = aws_eks_cluster.main.id
}

output "endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  value = aws_security_group.eks_cluster.id
}

#output "workers_security_group_id" {
 # value = aws_security_group.eks_workers.id
#}

output "eks_iam_role_arn" {
  value = aws_iam_role.eks.arn
}

output "eks_managed_nodes_iam_role_arn" {
  value = module.eks_managed_node_roles.arn
}