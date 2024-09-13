#Creating RDS Subnet group and RDS instance 
resource "aws_db_subnet_group" "three_tier_db_subnet_group" {
  name = "three_tier_db_subnet_group"
  subnet_ids = [
    aws_subnet.private_dbsubnet_az1.id,
    aws_subnet.private_dbsubnet_az2.id,
  ]
  tags = {
    name = "three-tier-db-subnet-group"
  }

}

resource "aws_rds_cluster" "database-1" {
  engine                 = "aurora-mysql"
  master_username        = "admin"
  master_password        = "Welcome$1041"
  cluster_identifier     = "database-1"
  db_subnet_group_name   = aws_db_subnet_group.three_tier_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.DB_tier_sg.id]
  #availability_zones     = ["us-east-1a", "us-east-1b"]
  skip_final_snapshot    = false
  final_snapshot_identifier = "mysnapshot"

  tags = {
    name = "database-1"
  }
}

resource "aws_rds_cluster_instance" "writer_instance" {
  cluster_identifier  = aws_rds_cluster.database-1.id
  instance_class      = "db.r5.large"
  engine              = "aurora-mysql"
  identifier          = "writer-instance"
  publicly_accessible = false
}

resource "aws_rds_cluster_instance" "reader_instance" {
  count = 1
  cluster_identifier  = aws_rds_cluster.database-1.id
  instance_class      = "db.r5.large"
  engine              = "aurora-mysql"
  identifier          = "reader-instance"
  publicly_accessible = false
}