# Aurora DB name
variable "db_name" {
  description = "Data Base name for Aurora"
  type        = string 
}
# Aurora DB Master Password 
variable "db_admin_password" {
  description = "The master password for the Aurora database"
  type        = string
  sensitive   = true
}

# Aurora DB Master Username
variable "db_admin_username" {
  description = "The master username for the Aurora database"
  type        = string
  sensitive   = true
}
variable "db_host" {
  description = "Data Base host for Aurora"
  type        = string 
}
variable "certificate_arn" {
  type = string
  description = "AWS ACM certificate ARN"
  
}