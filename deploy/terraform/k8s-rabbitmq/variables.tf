variable "eks_cluster_id" {
  description = "EKS Cluster ID"
}

variable "namespace" {
  description = "EKS namespace"
  default     = "default"
}

variable "user" {
  description = "auth.username"
  default     = "guest"
}

variable "password" {
  description = "auth.password"
  default     = "guest"
}

variable "erlang_cookie" {
  description = "auth.erlangCookie"
  default     = "dummy"
}

variable "requests_cpu" {
  description = "resources.requests.cpu"
  default     = "300m"
}

variable "requests_memory" {
  description = "resources.requests.memory"
  default     = "2Gi"
}

variable "limits_cpu" {
  description = "resources.requests.cpu"
  default     = "600m"
}

variable "limits_memory" {
  description = "resources.requests.memory"
  default     = "4Gi"
}

variable "replica" {
  description = "replica count"
  default     = "1"
}

variable "chart_version" {
  description = "Helm chart verion"
  default     = "8.29.1"
}
