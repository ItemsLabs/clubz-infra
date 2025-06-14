variable "eks_cluster_id" {
  description = "EKS Cluster ID"
}

variable "cluster_name" {
  description = "EKS Cluster name"
  default     = "default"
}

variable "namespace" {
  description = "EKS namespace"
  default     = "kube-system"
}

variable "chart_version" {
  description = "Helm chart verion"
  default     = "1.4.0"
}
