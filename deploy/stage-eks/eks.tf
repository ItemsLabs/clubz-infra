module "eks" {
  depends_on = [
   module.eks_vpc,
  ]
  source                  = "../terraform/eks-cluster"

  cluster_name            = local.cluster_name
  cluster_version         = local.eks_cluster_version
  env                     = var.env

  vpc_id                  = module.eks_vpc.vpc_id
  vpc_cidr_block          = module.eks_vpc.vpc_cidr_block
  subnet_ids              = concat(module.eks_vpc.public_subnets, module.eks_vpc.private_subnets)

  endpoint_private_access = true
  private_access_cidrs    = module.eks_vpc.private_subnets_cidr_blocks
  
  oidc_provider_enabled   = true

  tags                    = local.tags
}

module "eks_aws_auth" {
  source          = "../terraform/k8s-aws-auth"

  eks_cluster_id  = module.eks.cluster_id
  map_users  = [
    {
      userarn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/dmitry.kireev"
      username    = "dmitry.kireev"
      groups      = ["system:masters"]
    },
    {
      userarn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/igor.kotov"
      username    = "igor.kotov"
      groups      = ["system:masters"]
    },
    {
      userarn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/ivan.soto"
      username    = "ivan.soto"
      groups      = ["system:masters"]
    },
    {
      userarn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/muharrem@gameon.app"
      username    = "muharrem@gameon.app"
      groups      = ["system:masters"]
    },
    {
      userarn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Sergey"
      username    = "Sergey"
      groups      = ["system:masters"]
    },
  ]
  map_roles  = [
    {
      rolearn     = module.eks.eks_managed_nodes_iam_role_arn
      username    = "system:node:{{EC2PrivateDNSName}}"
      groups      = ["system:bootstrappers","system:nodes"]
    }
  ]
}

module "eks_managed_nodes" {
  depends_on = [
   module.eks,
  ]
  source                      = "../terraform/eks-managed-nodes"

  cluster_name                = local.cluster_name
  node_group_name             = "${local.cluster_name}-eks-managed-ng"
  node_role_arn               = module.eks.eks_managed_nodes_iam_role_arn
  cluster_security_group_id   = module.eks.cluster_security_group_id
  vpc_id                      = module.eks_vpc.vpc_id

  config = {
    desired_capacity          = 1             
    max_capacity              = 2             
    min_capacity              = 0             
    subnet_ids                = module.eks_vpc.private_subnets  # Identifiers of EC2 Subnets to associate with the EKS Node Group. These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME
    ami_type                  = "BOTTLEROCKET_x86_64"           # Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to AL2_x86_64. Valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM. Terraform will only perform drift detection if a configuration value is provided.
    capacity_type             = "ON_DEMAND"                     # Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT. 
    disk_size                 = 20            
    force_update_ami_version  = true          
    instance_types            = ["t3.medium"] 
  }

  tags                        = local.tags
}

####################
# Creating Namespace
# they were created manually:

resource "kubernetes_namespace_v1" "rabbitmq" {
  metadata {
    name = "rabbitmq"
  }
}
resource "kubernetes_namespace_v1" "env" {
  metadata {
    name = var.env
  }
}

module "k8s_fanclash_rabbitmq" {
  source          = "../terraform/k8s-rabbitmq"
  eks_cluster_id  = module.eks.cluster_id

  chart_version   = "8.29.1"
  namespace       = "rabbitmq"
  replica         = "1"

  user            = data.aws_ssm_parameter.rabbitmq_user.value
  password        = data.aws_ssm_parameter.rabbitmq_passwd.value
  erlang_cookie   = data.aws_ssm_parameter.rabbitmq_erlang_cookie.value

  requests_cpu    = "400m"
  requests_memory = "2Gi"
  limits_cpu      = "500m"
  limits_memory   = "3Gi"
}