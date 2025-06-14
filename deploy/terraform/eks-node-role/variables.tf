variable "name" {
  type        = string
  default     = null
  description = "The name of the node role."
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "The name of an EKS cluster"
}

variable "platform" {
  type        = string
  default     = "linux"
  description = "Node's platform can be linux, windows, bottlerocket, or fargate"
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

locals {
  s3_eks_iam_policy_statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:List*",
          "s3:Get*",
          "s3:*Object"
        ],
        Resource = "*"
      }
    ]
}
