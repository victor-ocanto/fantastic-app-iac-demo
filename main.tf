data "vault_generic_secret" "aurora" {
  path = "kv/fantastic-app-iac-demo/${local.environment}/aurora-db"
}

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
  common_tags             = local.common_tags
}

module "aurora" {
  source = "./modules/aurora"
  region = var.region
  environment = local.environment
  aurora_db_engine_mode = "provisioned"
  aurora_db_engine = "aurora-postgresql"
  aurora_db_bkp_retention = var.backup_retention_period
  aurora_db_deletion_protection = var.deletion_protection
  aurora_db_name = var.aurora_db_name
  aurora_master_password = data.vault_generic_secret.aurora.data["adminPassword"]
  aurora_master_username = data.vault_generic_secret.aurora.data["adminUser"]
  aurora_max_capacity = var.aurora_max_capacity
  aurora_min_capacity = var.aurora_min_capacity
  common_tags = local.common_tags
  priv_subnet_ids = module.vpc.private_subnet_ids
  vpc_id = module.vpc.vpc_id
  skip_final_snapshot = var.skip_final_snapshot
}