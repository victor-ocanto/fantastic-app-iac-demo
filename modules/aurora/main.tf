# Security Group for Aurora
resource "aws_security_group" "aurora_sg" {
  vpc_id = var.vpc_id
  name   = "aurora-security-group"

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
resource "aws_security_group_rule" "aurora_allow_private_subnets" {
  for_each          = toset(values(var.private_subnet_cidrs))
  security_group_id = aws_security_group.aurora_sg.id
  type             = "ingress"
  protocol         = "tcp"
  from_port        = 5432
  to_port          = 5432
  cidr_blocks      = [each.value] 
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
  cluster_identifier                    = "aurora-cluster-${var.environment}"
  engine                                =  var.aurora_db_engine
  engine_mode                           =  var.aurora_db_engine_mode
  database_name                         =  var.aurora_db_name
  master_username                       =  var.aurora_master_username
  master_password                       =  var.aurora_master_password
  db_subnet_group_name                  = aws_db_subnet_group.aurora.name
  vpc_security_group_ids                = [aws_security_group.aurora_sg.id]
  deletion_protection                   = var.aurora_db_deletion_protection 
  backup_retention_period               = var.aurora_db_bkp_retention
  skip_final_snapshot                   = var.skip_final_snapshot
  iam_database_authentication_enabled   = var.iam_db_auth_enabled
  performance_insights_enabled          = var.performance_insights_enabled
  storage_type                          = var.aurora_storage_type
  availability_zones                    = var.availability_zones

  serverlessv2_scaling_configuration {
    min_capacity = var.aurora_min_capacity  
    max_capacity = var.aurora_max_capacity  
  }

  lifecycle {
    ignore_changes = [
      availability_zones, 
      db_cluster_parameter_group_name
    ]
  }
  tags = merge(
    { Name = "Aurora-Cluster-${var.environment}" },
    var.common_tags
  )
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier                    = "aurora-cluster-${var.environment}-instance-1" 
  cluster_identifier            = aws_rds_cluster.aurora.cluster_identifier
  instance_class                = var.instance_class
  engine                        = aws_rds_cluster.aurora.engine
  engine_version                = aws_rds_cluster.aurora.engine_version
  performance_insights_enabled  = var.performance_insights_enabled

  tags = merge(
    { Name = "Aurora-instance-${var.environment}" },
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
