variable "region" {
  type        = string
  description = "The AWS region where resources will be deployed."
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to use for subnets."
}

variable "environment" {
  type        = string
  description = "The environment name, it depends on Terraform workspace"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources. It is defined on locals.tf"
}

variable "private_subnet_cidrs" {
  type        = map(string) 
  description = "Map of availability zones to private subnet CIDR blocks"
}
