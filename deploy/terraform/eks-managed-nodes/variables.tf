variable "cluster_name" {
  type        = string
  default     = null
  description = "The name of the EKS cluster."
}

variable "cluster_security_group_id" {
  type        = string
  default     = ""
  description = "ID of the cluster security group."
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "ID of the VPC."
}

variable "node_group_name" {
  type        = string
  default     = null
  description = "The name of the managed node group"
}

variable "node_role_arn" {
  type        = string
  default     = null
  description = "ARN of the IAM role that provides permissions for the EKS nodes."
}

variable "config" {
  type        = any
  default     = {}
  description = "Map with the managed node group parameters."
}

variable "create_timeout" {
  type        = string
  default     = "60m"
  description = "How long to wait for the EKS Node Group to be created."
}

variable "update_timeout" {
  type        = string
  default     = "60m"
  description = "How long to wait for the EKS Node Group to be updated."
}

variable "delete_timeout" {
  type        = string
  default     = "60m"
  description = "How long to wait for the EKS Node Group to be deleted."
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
