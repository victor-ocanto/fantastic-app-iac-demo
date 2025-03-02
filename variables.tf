variable "enable_nat_gateway" {
  default = true
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_count" {
  default = 3
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "eks_scaling_config" {
  type = object({
    desired_size  = number
    max_size      = number
    min_size      = number
  })
  default = {
    desired_size  = 1
    max_size      = 1
    min_size      = 1
  }
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.small"]
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
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
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