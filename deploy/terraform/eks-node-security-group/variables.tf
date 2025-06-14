variable "cluster_name" {
  type        = string
  default     = null
  description = "The name of the EKS cluster."
}

variable "cluster_security_group_id" {
  type        = string
  default     = null
  description = "The ID of the cluster's control plane security group."
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "The ID of the cluster's VPC."
}

variable "node_group_name" {
  type        = string
  default     = null
  description = "The name of the node group."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = <<EOT
     (Optional) Key-value map of resource tags.
     If configured with a provider default_tags configuration block present,
     tags with matching keys will overwrite those defined at the provider-level.
  EOT
}
