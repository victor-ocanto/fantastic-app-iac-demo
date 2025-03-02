# IAM 
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.eks_cluster_name}-eks-cluster-role"
  description = "IAM Role for EKS Cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "eks.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
 # Enable CloudWatch Container Insights
  tags = merge ({
    Name        = "${var.eks_cluster_name}-eks-cluster"},
    var.common_tags)
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  for_each = toset(var.eks_cluster_policies)

  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = each.key
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.eks_cluster_name}-eks-node-group-role"
  description = "IAM Role for Worker Nodes"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
    tags = merge ({
    Name        = "${var.eks_cluster_name}-eks-cluster"},
    var.common_tags)
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset(var.eks_node_policies)

  policy_arn = each.key
  role       = aws_iam_role.eks_node_group_role.name
}

# IAM OpenID Connect (OIDC) provider

resource "aws_iam_openid_connect_provider" "eks_iam_openid" {
  url             = aws_eks_cluster.main.identity.0.oidc.0.issuer
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  client_id_list  = ["sts.amazonaws.com"]

  depends_on = [aws_eks_cluster.main]
  tags = merge ({
    Name        = "${var.eks_cluster_name}-eks-cluster"},
    var.common_tags)
}

# Security Groups for EKS
resource "aws_security_group" "eks_cluster" {
  name        = "${var.eks_cluster_name}-eks-cluster-sg"
  vpc_id      = var.vpc_id
  description = "EKS Cluster Security Group"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge ({
    Name        = "${var.eks_cluster_name}-eks-cluster"},
    var.common_tags)
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.eks_cluster.id]
  }

  enabled_cluster_log_types = var.enable_logging ? ["api", "audit", "authenticator"] : []

  tags = merge ({
    "aws:eks:cluster-name"  = var.eks_cluster_name
    "aws:eks:enable-insights" = "true"},
    var.common_tags)

    lifecycle {
    ignore_changes = [tags_all, tags]  # Ignore AWS-managed tags
    }
}

data "tls_certificate" "oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}


#Node Group
resource "aws_eks_node_group" "main" {
  for_each = toset(var.availability_zones)

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.eks_cluster_name}-worker-group-${each.key}"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.subnet_ids


  scaling_config {
    desired_size = var.eks_scaling_config.desired_size
    max_size     = var.eks_scaling_config.max_size
    min_size     = var.eks_scaling_config.min_size
  }

  instance_types = var.worker_instance_types
  ami_type       = var.worker_ami_type

  tags = merge ({
    Name        = "${var.eks_cluster_name}-eks-cluster"},
    var.common_tags)
}
