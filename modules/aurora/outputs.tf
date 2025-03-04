output "aurora_cluster_endpoint" {
  value       = aws_rds_cluster.aurora.endpoint
  description = "The cluster endpoint of the Aurora PostgreSQL cluster"
}

output "aurora_reader_endpoint" {
  value       = aws_rds_cluster.aurora.reader_endpoint
  description = "The reader endpoint of the Aurora PostgreSQL cluster"
}
