module "vpc" {
  source             = "./modules/vpc"
  subnet_count       = var.subnet_count
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  region             = var.region
  environment        = local.environment
  common_tags        = local.common_tags
}

module "eks" {
  source                  = "./modules/eks"
  environment             = local.environment
  availability_zones      = var.availability_zones
  region                  = var.region
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids
  worker_ami_type         = var.ami_type
  worker_instance_types   = var.instance_types
  eks_scaling_config      = var.eks_scaling_config
  eks_cluster_name        = local.eks_cluster_name
  eks_node_policies       = var.eks_node_policies
  eks_cluster_policies    = var.eks_cluster_policies
}
