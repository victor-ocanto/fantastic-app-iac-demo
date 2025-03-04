variable "region" {
  type        = string
  description = "The AWS region where resources will be deployed."
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, staging, prod) for resource tagging and identification."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the EKS cluster and associated resources will be deployed."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs within the VPC where the EKS cluster and worker nodes will be deployed."
}

variable "availability_zones" {
  type        = list(string)
  description = "A list of availability zones to distribute resources across for high availability."
}

variable "enable_logging" {
  type        = bool
  default     = true
  description = "Enable or disable logging for the EKS cluster. Defaults to true."
}

variable "eks_scaling_config" {
  type = object({
    desired_size  = number
    max_size      = number
    min_size      = number
  })
  description = "Configuration for scaling the EKS worker node group, including desired, minimum, and maximum node counts."
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster to be created."
}

variable "worker_instance_types" {
  type        = list(string)
  description = "A list of EC2 instance types to use for EKS worker nodes."
}

variable "worker_ami_type" {
  type        = string
  description = "The AMI type to use for EKS worker nodes (e.g., AL2_x86_64, AL2_ARM_64)."
}

variable "eks_node_policies" {
  type        = list(string)
  description = "A list of IAM policy ARNs to attach to the EKS worker node IAM role."
}

variable "eks_cluster_policies" {
  type        = list(string)
  description = "A list of IAM policy ARNs to attach to the EKS cluster IAM role."
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources. These tags are defined in the locals.tf file."
}

variable "app_name" {
  type = string
  description = "Application name"
  
}

variable "ip_whitelist" {
  type = list(string)
  description = "list of IP that will be allowed to access to EKS API."
}