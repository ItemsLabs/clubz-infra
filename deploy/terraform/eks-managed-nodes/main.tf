resource "aws_eks_node_group" "managed_nodes" {
  node_group_name        = local.use_name_prefix ? null : var.node_group_name
  node_group_name_prefix = local.use_name_prefix ? local.config["name_prefix"] : null

  cluster_name  = var.cluster_name
  node_role_arn = var.node_role_arn
  subnet_ids    = local.config["subnet_ids"]

  scaling_config {
    desired_size = local.config["desired_capacity"]
    max_size     = local.config["max_capacity"]
    min_size     = local.config["min_capacity"]
  }

  ami_type             = local.config["ami_type"]
  release_version      = local.config["ami_version"]
  capacity_type        = local.config["capacity_type"]
  force_update_version = local.config["force_update_ami_version"]
  instance_types       = local.lt_enabled ? null : lookup(local.config, "instance_types", null)

  labels  = local.config["k8s_labels"]
  version = local.config["k8s_version"]

  launch_template {
    id      = local.lt_enabled ? lookup(local.config, "lt_id", null) : module.default_lt[0].id
    name    = local.lt_enabled ? lookup(local.config, "lt_name", null) : null
    version = local.lt_enabled ? lookup(local.config, "lt_version", null) : module.default_lt[0].latest_version
  }

  dynamic "remote_access" {
    for_each = local.config["keypair_name"] != null ? ["one"] : []
    content {
      ec2_ssh_key               = local.config["keypair_name"]
      source_security_group_ids = local.config["source_security_group_ids"]
    }
  }

  dynamic "taint" {
    for_each = local.config["taints"]
    content {
      key    = taint.value["key"]
      value  = lookup(taint.value, "value", null)
      effect = taint.value["effect"]
    }
  }

  tags = merge(
    var.tags,
    { Name = var.node_group_name }
  )

  lifecycle {
    #ignore_changes = [scaling_config[0].desired_size]
  }

}
