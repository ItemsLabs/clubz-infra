# ---------------------------------------------
# EKS Cluster SG
# ---------------------------------------------
resource "aws_security_group" "eks_cluster" {
    name_prefix = var.cluster_name
    description = "EKS Cluster communication with worker nodes"
    vpc_id      = var.vpc_id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = var.tags
}

# allow worker nodes to access EKS master
resource "aws_security_group_rule" "eks_cluster_ingress_node_https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  cidr_blocks              = var.private_access_cidrs
  

  type                     = "ingress"
}

# ---------------------------------------------
# Workers SG
# --------------------------------------------- 
/*
resource "aws_security_group" "eks_workers" {
    name_prefix = "eks-workers"
    description = "Security group for all nodes in the cluster"
    vpc_id      = var.vpc_id

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = var.tags
}

# Setup worker node security group
resource "aws_security_group_rule" "eks_workers_ingress_self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_workers.id
  source_security_group_id = aws_security_group.eks_workers.id
  to_port                  = 65535

  type                     = "ingress"
}
resource "aws_security_group_rule" "eks_workers_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_workers.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535

  type                     = "ingress"
}
resource "aws_security_group_rule" "eks_workers_ingress_master" {
  description              = "Allow cluster control to receive communication from the worker Kubelets"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_workers.id
  to_port                  = 443

  type                     = "ingress"
}
resource "aws_security_group_rule" "eks_workers_ssh" {
  description              = "Allow SSH connection to the EKS workers from VPC"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_workers.id
  cidr_blocks              = [var.vpc_cidr_block]
  to_port                  = 22

  type                     = "ingress"
}
*/

