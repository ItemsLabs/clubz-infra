locals {
  aws_auth = {
    rolearn  = one(aws_iam_role.eks_node_role[*].arn)
    username = var.platform == "fargate" ? "system:node:{{SessionName}}" : "system:node:{{EC2PrivateDNSName}}"
    groups = concat([
      "system:bootstrappers",
      "system:nodes"
      ],
      var.platform == "windows" ? ["eks:kube-proxy-windows"] : [],
      var.platform == "fargate" ? ["system:node-proxier"] : []
    )
  }
}

resource "aws_iam_role" "eks_node_role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_policy.json
  description        = format("Node role for the cluster %s", var.cluster_name)

  force_detach_policies = true

  tags = merge(
    var.tags,
    {
      Name    = var.name
      Cluster = var.cluster_name
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_node_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = data.aws_iam_policy.eks_node_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = data.aws_iam_policy.eks_node_ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = data.aws_iam_policy.eks_node_cni_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = data.aws_iam_policy.eks_worker_node_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = data.aws_iam_policy.eks_vpc_resource_controller_policy.arn
}

resource "aws_iam_policy" "s3_access" {
  name        = "eks-nodes-s3-access"
  description = "Read and Write S3 access for EKS nodes"

  policy = jsonencode({
    "Version"   = "2012-10-17",
    "Statement" = concat(local.s3_eks_iam_policy_statement)
  })
}

resource "aws_iam_policy_attachment" "s3_access" {
  name       = "eks-nodes-s3-access"
  roles      = [aws_iam_role.eks_node_role.name]
  policy_arn = aws_iam_policy.s3_access.arn
}

