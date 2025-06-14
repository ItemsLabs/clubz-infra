#--------------------------------------
# Node role policies
#--------------------------------------
data "aws_iam_policy_document" "eks_node_assume_policy" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# AWS managed policies for Amazon Elastic Kubernetes Service Nodes
# These policies must be attached as managed policies. You can't add them as inline one.

data "aws_iam_policy" "eks_node_policy" {
  name = "AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "eks_node_ecr_policy" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "eks_node_cni_policy" {
  name = "AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "eks_worker_node_policy" {
  name = "AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "eks_vpc_resource_controller_policy" {
  name = "AmazonEKSVPCResourceController"
}
