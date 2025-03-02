# Security Group for Aurora
resource "aws_security_group" "aurora_sg" {
  vpc_id = var.vpc_id
  name   = "aurora-security-group"

  # Allow inbound access from the application, restricted to private subnets only
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs 
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = "Aurora-SG-${var.environment}" },
    var.common_tags
  )
}

# Aurora Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group-${var.environment}"
  subnet_ids =  var.priv_subnet_ids

  tags = merge(
    { Name = "Aurora-Subnet-Group-${var.environment}" },
    var.common_tags
  )
}

# Aurora Cluster ( use serverless v2 for cost efficiency)
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-cluster-${var.environment}"
  engine                 =  var.aurora_db_engine
  engine_mode            =  var.aurora_db_engine_mode
  database_name          =  var.aurora_db_name
  master_username        =  var.aurora_master_username
  master_password        =  var.aurora_master_password
  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]
  deletion_protection    = var.aurora_db_deletion_protection 
  backup_retention_period = var.aurora_db_bkp_retention
  skip_final_snapshot      = var.skip_final_snapshot

  serverlessv2_scaling_configuration {
    min_capacity = var.aurora_min_capacity  
    max_capacity = var.aurora_max_capacity  
  }

  tags = merge(
    { Name = "Aurora-Cluster-${var.environment}" },
    var.common_tags
  )
}

# VPC Endpoint for RDS (to avoid public access)
resource "aws_vpc_endpoint" "rds_endpoint" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.rds"
  vpc_endpoint_type = "Interface"
  subnet_ids   =  var.priv_subnet_ids
  security_group_ids = [aws_security_group.aurora_sg.id]

  private_dns_enabled = true

  tags = merge(
    { Name = "RDS-VPC-Endpoint-${var.environment}" },
    var.common_tags
  )
}
