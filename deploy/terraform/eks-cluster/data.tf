data "aws_iam_policy_document" "eks_irsa_assume_role_policy" {
  count     = var.oidc_provider_enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.main[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.main[0].arn]
      type        = "Federated"
    }
  }
}

data "tls_certificate" "this" {
  count   = var.oidc_provider_enabled ? 1 : 0
  url     = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

data "aws_eks_cluster_auth" "eks" {
  count = var.oidc_provider_enabled ? 1 : 0
  name = aws_eks_cluster.main.id
}

data "http" "wait_for_cluster" {
  url            = format("%s/healthz", aws_eks_cluster.main.endpoint)
  ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  timeout        = var.cluster_wait_timeout

  depends_on = [
    aws_eks_cluster.main
  ]
}
