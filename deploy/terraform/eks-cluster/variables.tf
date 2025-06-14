variable "cluster_name" {
  default = "test-cluster"
  type    = string
}

variable "env" {
  type = string
}

variable "cluster_version" {
  default = "1.20"
  type    = string
}

variable "tags" {
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the EKS cluster"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  default     = [""]
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch the cluster in"
  type        = list(string)
}

variable "allowed_security_groups" {
  type        = list(string)
  default     = []
  description = "List of Security Group IDs to be allowed to connect to the EKS cluster"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the EKS cluster"
}

variable "create_eks_service_role" {
  type        = bool
  default     = true
  description = "Set `false` to use existing `eks_cluster_service_role_arn` instead of creating one"
}

variable "eks_cluster_service_role_arn" {
  type        = string
  description = <<-EOT
    The ARN of an IAM role for the EKS cluster to use that provides permissions
    for the Kubernetes control plane to perform needed AWS API operations.
    Required if `create_eks_service_role` is `false`, ignored otherwise.
    EOT
  default     = null
}

variable "workers_role_arns" {
  type        = list(string)
  description = "List of Role ARNs of the worker nodes"
  default     = []
}

variable "workers_security_group_ids" {
  type        = list(string)
  description = "Security Group IDs of the worker nodes"
  default     = []
}

variable "kubernetes_version" {
  type        = string
  default     = "1.21"
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
}

variable "oidc_provider_enabled" {
  type        = bool
  default     = false
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
}

variable "endpoint_private_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false"
}

variable "endpoint_public_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0."
}

variable "service_ipv4_cidr" {
  type        = string
  default     = null
  description = <<EOT
    (Optional) The CIDR block to assign Kubernetes service IP addresses from.
    If you don't specify a block, Kubernetes assigns addresses
    from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks.
    The block must meet the following requirements:
    - Within one of the following private IP address blocks: 10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16.
    - Doesn't overlap with any CIDR block assigned to the VPC that you selected for VPC.
    - Between /24 and /12.
  EOT
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 0
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}

variable "apply_config_map_aws_auth" {
  type        = bool
  default     = false
  description = "Whether to apply the ConfigMap to allow worker nodes to join the EKS cluster and allow additional users, accounts and roles to acces the cluster"
}

variable "map_additional_aws_accounts" {
  description = "Additional AWS account numbers to add to `config-map-aws-auth` ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_additional_iam_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_additional_iam_users" {
  description = "Additional IAM users to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "local_exec_interpreter" {
  type        = list(string)
  default     = ["/bin/sh", "-c"]
  description = "shell to use for local_exec"
}

variable "wait_for_cluster_command" {
  type        = string
  #default     = "curl --silent --fail --retry 60 --retry-delay 5 --retry-connrefused --insecure --output /dev/null $ENDPOINT/healthz"
  default     = "for i in `seq 1 60`; do curl -k -s $ENDPOINT/healthz >/dev/null && exit 0 || true; sleep 5; done; echo TIMEOUT && exit 1"
  description = "`local-exec` command to execute to determine if the EKS cluster is healthy. Cluster endpoint are available as environment variable `ENDPOINT`"
}

variable "kubernetes_config_map_ignore_role_changes" {
  type        = bool
  default     = true
  description = "Set to `true` to ignore IAM role changes in the Kubernetes Auth ConfigMap"
}

variable "cluster_encryption_config_enabled" {
  type        = bool
  default     = true
  description = "Set to `true` to enable Cluster Encryption Configuration"
}

variable "cluster_encryption_config_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS Key ID to use for cluster encryption config"
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  type        = bool
  default     = true
  description = "Cluster Encryption Config KMS Key Resource argument - enable kms key rotation"
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction"
}

variable "cluster_encryption_config_kms_key_policy" {
  type        = string
  default     = null
  description = "Cluster Encryption Config KMS Key Resource argument - key policy"
}

variable "cluster_encryption_config_resources" {
  type        = list(any)
  default     = ["secrets"]
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
}

variable "permissions_boundary" {
  type        = string
  default     = null
  description = "If provided, all IAM roles will be created with this permissions boundary attached."
}

variable "kubeconfig_path_enabled" {
  type        = bool
  default     = false
  description = "If `true`, configure the Kubernetes provider with `kubeconfig_path` and use it for authenticating to the EKS cluster"
}

variable "kubeconfig_path" {
  type        = string
  default     = ""
  description = "The Kubernetes provider `config_path` setting to use when `kubeconfig_path_enabled` is `true`"
}

variable "kube_data_auth_enabled" {
  type        = bool
  default     = true
  description = <<-EOT
    If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.
    Disabled by `kubeconfig_path_enabled` or `kube_exec_auth_enabled`.
    EOT
}

variable "kube_exec_auth_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.
    Disabled by `kubeconfig_path_enabled`, overrides `kube_data_auth_enabled`.
    EOT
}


variable "kube_exec_auth_role_arn" {
  type        = string
  default     = ""
  description = "The role ARN for `aws eks get-token` to use"
}

variable "kube_exec_auth_role_arn_enabled" {
  type        = bool
  default     = false
  description = "If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token`"
}

variable "kube_exec_auth_aws_profile" {
  type        = string
  default     = ""
  description = "The AWS config profile for `aws eks get-token` to use"
}

variable "kube_exec_auth_aws_profile_enabled" {
  type        = bool
  default     = false
  description = "If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token`"
}

variable "aws_auth_yaml_strip_quotes" {
  type        = bool
  default     = true
  description = "If true, remove double quotes from the generated aws-auth ConfigMap YAML to reduce spurious diffs in plans"
}

variable "dummy_kubeapi_server" {
  type        = string
  default     = "https://jsonplaceholder.typicode.com"
  description = <<-EOT
    URL of a dummy API server for the Kubernetes server to use when the real one is unknown.
    This is a workaround to ignore connection failures that break Terraform even though the results do not matter.
    You can disable it by setting it to `null`; however, as of Kubernetes provider v2.3.2, doing so _will_
    cause Terraform to fail in several situations unless you provide a valid `kubeconfig` file
    via `kubeconfig_path` and set `kubeconfig_path_enabled` to `true`.
    EOT
}

variable "addons" {
  type = list(object({
    addon_name               = string
    addon_version            = string
    resolve_conflicts        = string
    service_account_role_arn = string
  }))
  default     = []
  description = "Manages [`aws_eks_addon`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) resources."
}

variable "manage_aws_auth" {
  description = "Whether to apply the aws-auth configmap file."
  type        = bool
  default     = false
}

variable "aws_auth_additional_labels" {
  description = "Additional kubernetes labels applied on aws-auth ConfigMap"
  default     = {}
  type        = map(string)
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "(Optional) Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_create_timeout" {
  type        = string
  default     = "30m"
  description = "(Default 30 minutes) How long to wait for the EKS Cluster to be created."
}

variable "cluster_update_timeout" {
  type        = string
  default     = "60m"
  description = "(Default 60 minutes) How long to wait for the EKS Cluster to be updated."
}

variable "cluster_delete_timeout" {
  type        = string
  default     = "20m"
  description = "(Default 20 minutes) How long to wait for the EKS Cluster to be deleted."
}

variable "cluster_wait_timeout" {
  type        = number
  default     = 600   # 10 min
  description = "(Default 10 minutes) How long to wait for the EKS Cluster to be in ACTIVE state."
}

variable "extra_aws_auth_labels" {
  type        = map(string)
  default     = {}
  description = "Extra lables to assign to EKS aws-auth configmap."
}

variable "map_iam_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "Additional IAM users to add to the aws-auth configmap."
}

variable "map_iam_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "Additional IAM roles to add to the aws-auth configmap."
}

variable "map_iam_accounts" {
  type        = list(string)
  default     = []
  description = "AWS accounts to add to the aws-auth configmap."
}

variable "private_access_cidrs" {
  type        = list(string)
  default     = []
  description = <<EOT
    (Optional) List of CIDR blocks. Indicates which CIDR blocks can access
    the Amazon EKS private API server endpoint when enabled.
  EOT
}
