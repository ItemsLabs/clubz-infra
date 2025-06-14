#----------------------------------------
# Enabling IAM Roles for Service Accounts
# https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up-enable-IAM.html
#----------------------------------------

resource "aws_iam_openid_connect_provider" "main" {
  count           = var.oidc_provider_enabled ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer
  tags            = var.tags
}

# resource "aws_iam_role" "eks_irsa_assume_role" {
#   count              = var.oidc_provider_enabled ? 1 : 0

#   assume_role_policy = data.aws_iam_policy_document.eks_irsa_assume_role_policy[0].json
#   name               = "${var.cluster_name}-eks-irsa-role"
#   tags               = var.tags
# }
