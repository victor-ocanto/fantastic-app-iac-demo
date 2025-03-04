variable "region" {
  default = "us-east-1"
  description = "AWS region"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "Main VPC cidr"
}

variable "availability_zones" {
  type = list(string)
  description = "AWS Zones used for eks high availability"
}

variable "eks_scaling_config" {
  type = object({
    desired_size  = number
    max_size      = number
    min_size      = number
  })
  description = "EKS Scaling config"
}

variable "instance_types" {
  type        = list(string)
}

variable "ami_type" {
  type        = string
  default     = "AL2_x86_64"
}
variable "eks_node_policies" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess",
    "arn:aws:iam::aws:policy/AWSCertificateManagerReadOnly"
  ]
}
variable "eks_cluster_policies" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}
variable "aws_account_id" {
  type = string
  sensitive = true
}

variable "aurora_db_name" {
  type = string
  description = "The name depends on *.auto.tfvars"
}

variable "skip_final_snapshot" {
  type = bool
  description = "This variable depends on *.auto.tfvars"
}

variable "deletion_protection" {
  type = bool
  description = "This variable depends on *.auto.tfvars"
}
variable "backup_retention_period" {
  type = number
  description = "This variable depends on *.auto.tfvars"
}
variable "aurora_min_capacity" {
  type = number
  description = "This variable depends on *.auto.tfvars"
}
variable "aurora_max_capacity" {
  type = number
  description = "This variable depends on *.auto.tfvars"
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