

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "my-db-subnet-group"
  subnet_ids = aws_subnet.private_subnets.*.id

  tags = {
    Name = "My DB Subnet Group"
  }
}

resource "aws_db_subnet_group" "my_db_public_subnet_group" {
  name = "my-db-public-subnet-group"
  subnet_ids = aws_subnet.public_subnets.*.id

  tags = {
    Name = "My DB Subnet Group"
  }
}


resource "aws_rds_cluster" "aurora_postgres" {
  cluster_identifier     = "myauroracluster"
  engine                 = "aurora-postgresql"
  engine_version         = "16.4"
  database_name          = "dev_postgres"
  master_username        = "dev_postgres_user"
  master_password        = "dev_postgres"
  vpc_security_group_ids = [aws_security_group.allow_aurora.id]
  db_subnet_group_name   = aws_db_subnet_group.my_db_public_subnet_group.name
  storage_encrypted      = false
  skip_final_snapshot    = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier          = "muaurorainstance"
  cluster_identifier  = aws_rds_cluster.aurora_postgres.id
  instance_class      = "db.t4g.medium"
  engine              = aws_rds_cluster.aurora_postgres.engine
  engine_version      = aws_rds_cluster.aurora_postgres.engine_version
  publicly_accessible = true
}