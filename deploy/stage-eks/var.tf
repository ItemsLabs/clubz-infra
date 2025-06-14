
variable "env" {
  default = "qa"
}
variable "aws_profile" {
  default = "infra-dev"
}

variable "namespace" {
  default = "gameon"
}
variable "aws_region" {
  default = "us-east-1"
}
variable "root_domain_name" {
  default = "gamebuild.co"
}

variable "ssh_public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCSN+0CUz7kmxFhNTZQf+7BOrvg2yIIdZt06IVmM60MgpjdOGKPtzE4GYx5AhnGCpCjrdatYhhF1nXHxay/srhsP4BLhEquWUxIdVLK4SIGBFgk7+3EbggJ3qY6EhU7qKmttNh9+7Wi2v7+rNwlPZ8fwwxHWKCofynlVPMeNRO9L0xE1WsQQK7BvSk9f5FbYUQ6PZUne52u5lCyahWtp/66rEbROLeAaA6o5UkWdaS4/hEBwje+q+O5hqQvikeLs5p4HOBH+RoH91V3p9svd/a9utXCw5OJ6DlenO9lX9pPD+xXOYXIGqfeUaxoi2EQ6kLJcnvU7Iw8G3I/bIAgAgQMgbKePLtWp4gYLGsuks1ZD0nWs2UfikEKmFCLBeY8Xlsm2OdbpPHqp8zF9gAlfRti23/RUQZ/58AXcmsFCoTuSHKNOWslg2dIZqSqQOgKsL+eVL2DZWhq1tTG1UWUjCcJbXBxRAVMEzbi8mydgyc3Ww7ljV8oaGSglW5/sPZqb/8= pc@Muharrems-MacBook-Pro.local"
}
variable "ec2_key_pair_name" {
  default = "fanclash"
}
# variable "docker_registry" {}
# variable "docker_image_tag" {}

locals {
  cluster_name        = "${var.env}-${var.namespace}"
  eks_cluster_version = "1.21"

  tags = {
    terraform         = "true"
    namespace         = var.namespace
    env               = var.env
  }
}
