resource "aws_launch_template" "lt" {
  count = var.create ? 1 : 0

  name        = var.name_prefix == null ? var.name : null
  name_prefix = var.name_prefix
  description = var.description

  default_version        = var.default_version
  update_default_version = var.update_default_version

  image_id      = var.ami_id
  instance_type = var.instance_type
  user_data     = var.user_data
  kernel_id     = var.kernel_id
  key_name      = var.key_name
  ebs_optimized = var.ebs_optimized
  ram_disk_id   = var.ram_disk_id


  disable_api_termination              = var.enable_termination_protection
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  security_group_names   = var.security_group_ids
  vpc_security_group_ids = var.vpc_security_group_ids

  tags = var.tags

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = block_device_mappings.value.device_name
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = flatten([lookup(block_device_mappings.value, "ebs", [])])
        content {
          delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          encrypted             = lookup(ebs.value, "encrypted", null)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          iops                  = lookup(ebs.value, "iops", null)
          throughput            = lookup(ebs.value, "throughput", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
        }
      } # ebs
    }
  } # block device mappings

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_preference != null ? ["one"] : []
    content {
      capacity_reservation_preference = var.capacity_reservation_preference

      dynamic "capacity_reservation_target" {
        for_each = var.capacity_reservation_id != null ? ["one"] : []
        content {
          capacity_reservation_id = var.capacity_reservation_id
        }
      } # capacity reservation target
    }
  } # capacity reservation specification

  dynamic "cpu_options" {
    for_each = var.cpu_core_count != null ? ["one"] : []
    content {
      core_count       = var.cpu_core_count
      threads_per_core = var.cpu_threads_per_core
    }
  } # cpu options

  dynamic "credit_specification" {
    for_each = var.cpu_credits != null ? ["one"] : []
    content {
      cpu_credits = var.cpu_credits
    }
  } # credit_specification

  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_type != null ? ["one"] : []
    content {
      type = var.elastic_gpu_type
    }
  } # elastic gpu specifications

  dynamic "elastic_inference_accelerator" {
    for_each = var.elastic_inference_type != null ? ["one"] : []
    content {
      type = var.elastic_inference_type
    }
  } # elastic inference accelerator

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile_name != null || var.iam_instance_profile_arn != null ? ["one"] : []
    content {
      name = var.iam_instance_profile_name
      arn  = var.iam_instance_profile_arn
    }
  } # iam instance profile

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? ["one"] : []
    content {
      market_type = "spot"
      spot_options {
        instance_interruption_behavior = lookup(var.instance_market_options, "instance_interruption_behavior", "terminate")
        max_price                      = lookup(var.instance_market_options, "spot_max_price", "")
        spot_instance_type             = lookup(var.instance_market_options, "spot_request_type", "persistent")
        valid_until                    = lookup(var.instance_market_options, "spot_request_valid_until", null)
      }
    }
  } # instance market options

  dynamic "license_specification" {
    for_each = var.license_configuration_arns
    content {
      license_configuration_arn = each.value
    }
  } # license specification

  metadata_options {
    http_endpoint               = var.metadata_enable_service ? "enabled" : "disabled"
    http_tokens                 = var.metadata_require_http_token ? "required" : "optional"
    http_put_response_hop_limit = var.metadata_response_hop_limit
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_carrier_ip_address = lookup(network_interfaces.value, "associate_carrier_ip_address", null)
      associate_public_ip_address  = lookup(network_interfaces.value, "associate_public_ip_address", null)
      delete_on_termination        = lookup(network_interfaces.value, "delete_on_termination", null)
      description                  = lookup(network_interfaces.value, "description", null)
      device_index                 = lookup(network_interfaces.value, "device_index", null)
      ipv4_addresses               = lookup(network_interfaces.value, "ipv4_addresses", null) != null ? network_interfaces.value.ipv4_addresses : []
      ipv4_address_count           = lookup(network_interfaces.value, "ipv4_address_count", null)
      ipv6_addresses               = lookup(network_interfaces.value, "ipv6_addresses", null) != null ? network_interfaces.value.ipv6_addresses : []
      ipv6_address_count           = lookup(network_interfaces.value, "ipv6_address_count", null)
      network_interface_id         = lookup(network_interfaces.value, "network_interface_id", null)
      private_ip_address           = lookup(network_interfaces.value, "private_ip_address", null)
      security_groups              = lookup(network_interfaces.value, "security_groups", null) != null ? network_interfaces.value.security_groups : []
      subnet_id                    = lookup(network_interfaces.value, "subnet_id", null)
    }
  } # network interfaces

  dynamic "placement" {
    for_each = var.placement != null ? ["one"] : []
    content {
      affinity          = lookup(placement.value, "affinity", null)
      availability_zone = lookup(placement.value, "availability_zone", null)
      group_name        = lookup(placement.value, "group_name", null)
      host_id           = lookup(placement.value, "host_id", null)
      spread_domain     = lookup(placement.value, "spread_domain", null)
      tenancy           = lookup(placement.value, "tenancy", null)
      partition_number  = lookup(placement.value, "partition_number", null)
    }
  } # placement

  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = tag_specifications.value.tags
    }
  } # tag specifications

  hibernation_options {
    configured = var.enable_hibernation
  }

  enclave_options {
    enabled = var.enable_enclave
  }
}
