terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.62"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 1.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0.0"
    }
  }
}
