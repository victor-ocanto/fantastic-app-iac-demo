locals {
  eks_cluster_name = "${terraform.workspace}-${var.region}"
  environment           = terraform.workspace
  common_tags           = {
    Environment         = terraform.workspace
    ManagedBy           = "Terraform"
  }
  private_subnet_cidrs  = {
    for i, az in var.availability_zones : az => cidrsubnet("10.0.0.0/16", 3, i + length(var.availability_zones))
  }
  app_name              = "fantastic-app"
  ip_whitelist          = ["0.0.0.0/0"]
}
