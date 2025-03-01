locals {
  eks_cluster_name = "${terraform.workspace}-${var.region}"
  environment = terraform.workspace
  ip_whitelist =  ["45.225.214.110/32","179.0.239.90/32"]
  common_tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}
