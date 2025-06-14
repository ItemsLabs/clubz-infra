locals {
  default_config = {
    desired_capacity          = 1             # Desired number of worker nodes.
    max_capacity              = 2             # Maximum number of worker nodes.
    min_capacity              = 0             # Minimum number of worker nodes.
    subnet_ids                = []            # Identifiers of EC2 Subnets to associate with the EKS Node Group. These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME
    ami_type                  = "AL2_x86_64"  # Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Defaults to AL2_x86_64. Valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM. Terraform will only perform drift detection if a configuration value is provided.
    capacity_type             = "ON_DEMAND"   # Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT. Terraform will only perform drift detection if a configuration value is provided.
    disk_size                 = 20            # Disk size in GiB for worker nodes. Defaults to 20. Terraform will only perform drift detection if a configuration value is provided.
    force_update_ami_version  = true          # Force version update if existing pods are unable to be drained due to a pod disruption budget issue.
    instance_types            = ["t3.medium"] # Set of instance types associated with the EKS Node Group. Defaults to ["t3.medium"]. Terraform will only perform drift detection if a configuration value is provided.
    k8s_labels                = {}            # Key-value map of Kubernetes labels. Only labels that are applied with the EKS API are managed by this argument. Other Kubernetes labels applied to the EKS Node Group will not be managed.
    lt_id                     = null          # Identifier of the EC2 Launch Template. Conflicts with name.
    lt_name                   = null          # Name of the EC2 Launch Template. Conflicts with id. EC2 Launch Template version number. While the API accepts values like $Default and $Latest, the API will convert the value to the associated version number (e.g. 1) on read and Terraform will show a difference on next plan. Using the default_version or latest_version attribute of the aws_launch_template resource or data source is recommended for this argument.
    lt_version                = null          # EC2 Launch Template version number. While the API accepts values like $Default and $Latest, the API will convert the value to the associated version number (e.g. 1) on read and Terraform will show a difference on next plan. Using the default_version or latest_version attribute of the aws_launch_template resource or data source is recommended for this argument.
    ami_version               = null          # AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version.
    keypair_name              = null          # EC2 Key Pair name that provides access for SSH communication with the worker nodes in the EKS Node Group. If you specify this configuration, but do not specify source_security_group_ids when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0).
    source_security_group_ids = []            # Set of EC2 Security Group IDs to allow SSH access (port 22) from on the worker nodes. If you specify ec2_ssh_key, but do not specify this configuration when you create an EKS Node Group, port 22 on the worker nodes is opened to the Internet (0.0.0.0/0).
    taints                    = []            # The Kubernetes taints to be applied to the nodes in the node group. Maximum of 50 taints per node group.
    k8s_version               = null          # Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided.
  }

  config = merge(
    local.default_config,
    var.config
  )

  lt_enabled      = lookup(local.config, "lt_id", null) != null || lookup(local.config, "lt_name", null) != null
  use_name_prefix = lookup(local.config, "name_prefix", null) != null
}
