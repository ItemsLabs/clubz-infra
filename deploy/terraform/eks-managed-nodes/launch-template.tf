# Duplicates the default launch templated created by EKS
module "default_lt" {
  count  = local.lt_enabled ? 0 : 1
  source = "../eks-ec2-launch-template"

  name                   = var.node_group_name
  description            = format("Default launch template for the EKS managed node group %s", var.node_group_name)
  update_default_version = true

  instance_initiated_shutdown_behavior = null # Allows EKS to manage instance shutdown behaviour on it's own

  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = [
        {
          volume_size           = lookup(local.config, "disk_size", 20)
          volume_type           = "gp2"
          delete_on_termination = true
        }
      ]
    }
  ]

  network_interfaces = [
    {
      delete_on_termination = true
      security_groups       = compact([module.default_sg.id])
    }
  ]

  tags = merge(
    var.tags,
    { Name = var.node_group_name }
  )
}
