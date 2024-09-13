output "app_tier_subnet_id" {
  value = aws_subnet.private_subnet_az1.id
}
output "app_tier_sg" {
  value = [aws_security_group.Private_App_tier_sg.id]
}

output "RDS_endpoint" {
  value = aws_rds_cluster_instance.writer_instance.endpoint
}
