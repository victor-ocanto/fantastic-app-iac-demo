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

#/*
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token

}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
#*/
/*
## workaround to https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1234
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
*/
