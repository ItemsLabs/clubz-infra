data "aws_ssm_parameter" "gameon_app_postgres_passwd" {
  name = "/${var.env}/global/fanclash/POSTGRES_PASSWORD"
}

module "aurora_eks_app_postgres" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 4.0"

  name            = "${var.env}-fanclash-postgres"
  database_name   = "fanclash"

  engine          = "aurora-postgresql"
  engine_version  = "11.13"
  instance_type   = "db.r4.large"
  replica_count   = 1

  vpc_id  = module.eks_vpc.vpc_id
  subnets = module.eks_vpc.private_subnets
  # TODO: Tight up security group
  allowed_security_groups = [
    aws_security_group.default_permissive.id
  ]
  allowed_cidr_blocks     = module.eks_vpc.private_subnets_cidr_blocks
  
  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10
  password            = data.aws_ssm_parameter.gameon_app_postgres_passwd.value

  tags = local.tags
}

resource "aws_route53_record" "eks_db_app_postgres" {
  zone_id = aws_route53_zone.env_domain.id
  name    = "db-fanclash-postgres.${var.env}.${var.root_domain_name}"
  type    = "CNAME"
  ttl     = "900"
  records = [
    module.aurora_eks_app_postgres.this_rds_cluster_endpoint
  ]
}

# SSM Secrets - aurora_app_postgres
resource "aws_ssm_parameter" "eks_app_postgres_user" {
  name  = "/${var.env}/global/fanclash/POSTGRES_USERNAME"
  type  = "SecureString"
  value = module.aurora_eks_app_postgres.this_rds_cluster_master_username
}

