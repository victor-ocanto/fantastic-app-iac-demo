provider "aws" {
  region = var.region# Specify your AWS region
}

provider "tls" {}

data "aws_eks_cluster" "eks" {
  name = local.eks_cluster_name
  depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "eks" {
  name = local.eks_cluster_name
  depends_on = [ module.eks ]
}

provider "vault" {
  address = "http://127.0.0.1:8200"
}