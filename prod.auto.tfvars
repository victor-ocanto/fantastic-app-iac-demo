aurora_db_name          = "prod"
skip_final_snapshot     = false 
deletion_protection     = true
backup_retention_period = 1
aurora_min_capacity     = 0.5
aurora_max_capacity     = 20
availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
eks_scaling_config      = { desired_size  = 1
                            max_size      = 10
                            min_size      = 1
                            }
instance_types              = ["t3.medium"]
aurora_storage_type         = "aurora-iopt1"
performance_insights_enabled = true
instance_class               = "db.serverless"  
iam_db_auth_enabled          = true