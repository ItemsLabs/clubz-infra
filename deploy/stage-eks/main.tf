module "eks_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "${var.env}-vpc"
  cidr                 = "10.200.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24"]
  public_subnets       = ["10.200.4.0/24", "10.200.5.0/24", "10.200.6.0/24"]
  enable_vpn_gateway   = false
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags                 = merge(local.tags, 
  {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  })
  public_subnet_tags  = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_security_group" "default_permissive" {
  name   = "fanclash-default-permissive"
  vpc_id = module.eks_vpc.vpc_id

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform = "true"
    Env       = var.env
    Name      = "fanclash-default-permissive"
  }
}

resource "aws_route53_zone" "env_domain" {
  name = "${var.env}.${var.root_domain_name}"
}

resource "aws_key_pair" "root" {
  key_name   = var.ec2_key_pair_name
  public_key = var.ssh_public_key
}

module "openvpn_instance" {
  source  = "hazelops/ec2-openvpn-connector/aws"
  version = "~> 0.2"

  vpn_enabled     = false
  bastion_enabled = true

  env                 = var.env
  vpc_id              = module.eks_vpc.vpc_id
  allowed_cidr_blocks = [module.eks_vpc.vpc_cidr_block]
  private_subnets     = module.eks_vpc.private_subnets
  ec2_key_pair_name   = var.ec2_key_pair_name

  ssh_forward_rules = [
    "LocalForward 30432 ${module.aurora_eks_app_postgres.this_rds_cluster_endpoint}:${module.aurora_eks_app_postgres.this_rds_cluster_port}"
  ]
}
