output "kubeconfig" {
  value = aws_eks_cluster.main.endpoint
}

output "node_group_details" {
  value = [for ng in aws_eks_node_group.main : {
    name        = ng.node_group_name
    instance_id = ng.id
  }]
}

#it is needed on monitoring module
output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

data "aws_eks_cluster" "eks" {
  name =  aws_eks_cluster.main.name
}

output "oidc_provider" {
  value = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
}
