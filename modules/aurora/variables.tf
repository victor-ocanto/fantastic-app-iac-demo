
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

# Private Subnet CIDR blocks (you can extend this if needed)
variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]  # Adjust as needed
}

# VPC endpoint security group
variable "rds_endpoint_sg" {
  description = "Security Group for RDS VPC Endpoint"
  type        = string
  default     = "sg-12345678"  # Replace with your security group ID
}

variable "environment" {
  description = "Environment for resource tagging"
  type        = string
}

# Aurora DB Master Password (best to handle securely)
variable "aurora_master_password" {
  description = "The master password for the Aurora database"
  type        = string
  sensitive   = true
}

# Aurora DB Master Username
variable "aurora_master_username" {
  description = "The master username for the Aurora database"
  type        = string
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
# Aurora DB name deletion protection
variable "aurora_db_bkp_retention" {
  description = "backup retention period in days"
  type        = string 
}

# Scaling configuration for Aurora Serverless
variable "aurora_min_capacity" {
  description = "Minimum Aurora capacity unit"
  type        = number
  default     = 0.5  # Adjust as needed
}

variable "aurora_max_capacity" {
  description = "Maximum Aurora capacity unit"
  type        = number
  default     = 4  # Adjust as needed
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


