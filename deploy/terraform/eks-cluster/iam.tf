locals {
  cloudwatch_put_metric_iam_policy_statement = [
    {
      Effect   = "Allow",
      Action   = [
          "cloudwatch:PutMetricData"
      ],
      Resource = "*"
    }
  ]
  
  ec2_elb_iam_policy_statement = [
    {
      Effect   = "Allow",
      Action   = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeInternetGateways"
      ],
      Resource = "*"
    }
  ]

}
resource "aws_iam_role" "eks" {
  name = "${var.cluster_name}-eks-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "eks.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "cloudwatch_put_metrics" {
  name          = "${var.cluster_name}-eks-cloudwatch-metrics"
  description   = "Read and Write CloudWatch Metrics"

  policy = jsonencode({
  "Version"  = "2012-10-17",
  "Statement" = concat(local.cloudwatch_put_metric_iam_policy_statement)
  })
}

resource "aws_iam_policy_attachment" "cloudwatch_put_metrics" {
  name       = "cloudwatch-metrics-attachment"
  roles      = [aws_iam_role.eks.name]
  policy_arn = aws_iam_policy.cloudwatch_put_metrics.arn
}

resource "aws_iam_policy" "ec2_elb" {
  name          = "${var.cluster_name}-eks-ec2-elb"

  policy = jsonencode({
  "Version"  = "2012-10-17",
  "Statement" = concat(local.ec2_elb_iam_policy_statement)
  })
}

resource "aws_iam_policy_attachment" "ec2_elb" {
  name       = "ec2-elb-attachment"
  roles      = [aws_iam_role.eks.name]
  policy_arn = aws_iam_policy.ec2_elb.arn
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks.name
}

# ---------------------------------------------
# EKS Node Managed Role
# ---------------------------------------------
module "eks_managed_node_roles" {
  source   = "../eks-node-role"

  name         = "${var.cluster_name}-eks-node-managed"
  cluster_name = var.cluster_name
  tags         = var.tags
}
