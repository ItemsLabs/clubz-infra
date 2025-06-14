variable "env" {
  description = "Environment name [dev, prod]"
  type        = string
}

variable "namespace" {
  description = "Application namespace (eg, gameon, whitel)"
  type        = string
  default     = "gameon"
}

variable "name" {
  description = "Name of this distinct component"
  type        = string
}

variable "is_fifo" {
  description = "Controls whether queue is created in FIFO mode"
  type        = bool
  default     = true
}

variable "message_ttl" {
  description = "Maximum time (in seconds) a message can spend in the queue before being purged"
  type        = number
  default     = 60 * 60 * 24 # 1 day
}
