data "aws_eks_cluster" "this" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_id
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "helm_release" "rabbitmq" {
  name        = "rabbitmq"
  repository  = "https://charts.bitnami.com/bitnami"
  chart       = "rabbitmq"
  version     = var.chart_version
  namespace   = var.namespace

  set {
    name  = "replicaCount"
    value = var.replica
  }
  
  set {
    name  = "auth.username"
    value = var.user
  }

  set_sensitive {
    name  = "auth.password"
    value = var.password    
  }

  set {
    name  = "auth.erlangCookie"
    value = var.erlang_cookie
  }

  set {
    name  = "resources.requests.cpu"
    value =  var.requests_cpu
  }

  set {
    name  = "resources.requests.memory"
    value = var.requests_memory
  }

    set {
    name  = "resources.limits.cpu"
    value =  var.limits_cpu
  }

  set {
    name  = "resources.limits.memory"
    value = var.limits_memory
  }

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "image.repository"
    value = "bitnami/rabbitmq"
  }
  set {
    name  = "image.tag"
    value = "latest"
  }

  set {
    name  = "image.debug"
    value = "true"
  }

}

