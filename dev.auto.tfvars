aurora_db_name              = "dev"
skip_final_snapshot         = true 
deletion_protection         = false
backup_retention_period     = 1
aurora_min_capacity         = 0.5
aurora_max_capacity         = 1
eks_scaling_config          = { desired_size  = 1
                            max_size      = 1
                            min_size      = 1
                            }
availability_zones          = ["us-east-1a", "us-east-1b"]
instance_types              = ["t3.small"]
aurora_storage_type         = "aurora"
performance_insights_enabled = false
instance_class               = "db.serverless"  
iam_db_auth_enabled          = false