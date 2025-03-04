
# AWS Region
variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# Common tags to apply to resources
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

variable "environment" {
  description = "Environment for resource tagging, set on *.auto.tfvars"
  type        = string
}

# Aurora DB Master Password 
variable "aurora_master_password" {
  description = "The master password for the Aurora database"
  type        = string
  sensitive   = true
}

# Aurora DB Master Username
variable "aurora_master_username" {
  description = "The master username for the Aurora database"
  type        = string
  sensitive   = true
}

# Aurora DB Engine
variable "aurora_db_engine" {
  description = "The engine for Aurora"
  type        = string
  default     = "aurora-mysql"
}

# Aurora DB Engine mode
variable "aurora_db_engine_mode" {
  description = "The engine for Aurora"
  type        = string
  default     = "provisioned"  
}

# Aurora DB name
variable "aurora_db_name" {
  description = "Data Base name for Aurora"
  type        = string 
}

# Aurora DB name deletion protection
variable "aurora_db_deletion_protection" {
  description = "deletion protection of Aurora DB"
  type        = string 
}
# Aurora DB backup retention
variable "aurora_db_bkp_retention" {
  description = "backup retention period in days"
  type        = string 
}

# Scaling configuration for Aurora Serverless
variable "aurora_min_capacity" {
  description = "Minimum Aurora capacity unit"
  type        = number
  default     = 0.5 
}

variable "aurora_max_capacity" {
  description = "Maximum Aurora capacity unit"
  type        = number
  default     = 4
}

variable "vpc_id" {
  type = string
  description = "Main VPC"
}

variable "priv_subnet_ids" {
  type = list(string)
  description = "subnets created in VPC module"
}

variable "skip_final_snapshot" {
  type = bool
  description = "skip final snapshot when deleting the DB"
}

variable "private_subnet_cidrs" {
  type        = map(string) 
  description = "Map of availability zones to private subnet CIDR blocks"
}

variable "aurora_storage_type" {
  description = "The storage type for the Aurora cluster"
  type        = string
}

variable "instance_class" {
  description = "The instance class for the Aurora cluster"
  type        = string
}
variable "iam_db_auth_enabled" {
  type = bool
  description = "Whether to enable IAM database authentication for the Aurora cluster"
}
variable "performance_insights_enabled" {
  description = "Whether to enable Performance Insights for the Aurora cluster"
  type        = bool
}

variable "availability_zones" {
  type        = list(string)
  description = "A list of availability zones to distribute resources across for high availability."
}