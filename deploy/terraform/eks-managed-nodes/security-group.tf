module "default_sg" {
  source = "../eks-node-security-group"

  cluster_name              = var.cluster_name
  cluster_security_group_id = var.cluster_security_group_id
  vpc_id                    = var.vpc_id

  node_group_name = var.node_group_name
  tags            = var.tags
}
