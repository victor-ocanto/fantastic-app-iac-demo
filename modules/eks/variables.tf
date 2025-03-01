variable "region" {
  type = string
}
variable "environment" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "availability_zones" {
   type = list(string)
}
variable "enable_logging" {
    type = bool
   default = true
}

variable "eks_scaling_config" {
  type = object({
    desired_size  = number
    max_size      = number
    min_size      = number
  })
}
variable "eks_cluster_name" {
  type = string
}

variable "worker_instance_types" {
  type        = list(string)
}

variable "worker_ami_type" {
  type        = string
}
variable "eks_node_policies" {
  type = list(string)
}
variable "eks_cluster_policies" {
  type = list(string)
}
