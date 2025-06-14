data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_api_gateway_rest_api" "blockchain-service-staging" {
  name = "blockchain-service-staging"
}

data "aws_ami" "amazon_linux_ecs_generic" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

data "aws_route53_zone" "root" {
  name         = "${var.root_domain_name}."
  private_zone = false
}

data "aws_default_tags" "provider" {}

data "aws_vpc_endpoint_service" "execute_api" {
  service = "execute-api"
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

data "aws_ssm_parameter" "rabbitmq_user" {
  name  = "/${var.env}/eks/fanclash/RABBITMQ_USER"
}
data "aws_ssm_parameter" "rabbitmq_passwd" {
  name  = "/${var.env}/eks/fanclash/RABBITMQ_PASSWORD"
}
data "aws_ssm_parameter" "rabbitmq_erlang_cookie" {
  name  = "/${var.env}/eks/fanclash/RABBITMQ_ERLANG_COOKIE"
}

data "aws_ssm_parameter" "fcm_creds_private_key" {
  name = "/${var.env}/eks/fanclash/FCM_CREDENTIALS/private_key"
}

data "aws_ssm_parameter" "fcm_creds_private_key_id" {
  name = "/${var.env}/eks/fanclash/FCM_CREDENTIALS/private_key_id"
}

data "aws_ssm_parameter" "fcm_creds_client_id" {
  name = "/${var.env}/eks/fanclash/FCM_CREDENTIALS/client_id"
}

data "aws_ssm_parameter" "ortec_user" {
  name = "/${var.env}/eks/fanclash/ORTEC_USERNAME"
}

data "aws_ssm_parameter" "ortec_paswd" {
  name = "/${var.env}/eks/fanclash/ORTEC_PASSWORD"
}

data "aws_ssm_parameter" "gce_opta_fee_private_key" {
  name = "/${var.env}/eks/fanclash/gce_opta_feed/private_key"
}

data "aws_ssm_parameter" "gce_opta_feed_private_key_id" {
  name = "/${var.env}/eks/fanclash/gce_opta_feed/private_key_id"
}

data "aws_ssm_parameter" "gce_opta_feed_client_id" {
  name = "/${var.env}/eks/fanclash/gce_opta_feed/client_id"
}

data "aws_ssm_parameter" "revenue_cat_api_key" {
  name = "/${var.env}/eks/fanclash/REVENUE_CAT_API_KEY"
}

data "aws_ssm_parameter" "fanclash_app_postgres_passwd" {
  name = "/${var.env}/global/fanclash/POSTGRES_PASSWORD"
}

data "aws_iam_policy_document" "fanclashpi_public_bucket_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Deny"

    actions = [
      "s3:PutObject*",
			"s3:DeleteObject*",
    ]

    resources = [
      "arn:aws:s3:::${var.env}-fanclash-player-images",
      "arn:aws:s3:::${var.env}-fanclash-player-images/*",
    ]
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name}-eks-node-managed"
      ]
    }
  }

  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.env}-fanclash-player-images/*",
    ]
  }
}

data "aws_iam_policy_document" "fanclashtc_public_bucket_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Deny"

    actions = [
      "s3:PutObject*",
			"s3:DeleteObject*",
    ]

    resources = [
      "arn:aws:s3:::${var.env}-fanclash-team-crests",
      "arn:aws:s3:::${var.env}-fanclash-team-crests/*",
    ]
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name}-eks-node-managed"
      ]
    }
  }

  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.env}-fanclash-team-crests/*",
    ]
  }
}

data "aws_iam_policy_document" "fanclashua_public_bucket_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Deny"

    actions = [
      "s3:PutObject*",
			"s3:DeleteObject*",
    ]

    resources = [
      "arn:aws:s3:::${var.env}-fanclash-user-avatars",
      "arn:aws:s3:::${var.env}-fanclash-user-avatars/*",
    ]
    condition {
      test     = "ArnNotLike"
      variable = "aws:PrincipalArn"
      values = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name}-eks-node-managed"
      ]
    }
  }

  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.env}-fanclash-user-avatars/*",
    ]
  }
}
