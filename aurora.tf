

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


resource "aws_rds_cluster" "aurorards" {
  cluster_identifier     = "myauroracluster"
  engine                 = "aurora-postgresql"
  engine_version         = "16.4"
  database_name          = "MyDB"
  master_username        = "user123"
  master_password        = "blueCarRed123"
  vpc_security_group_ids = [aws_security_group.allow_aurora.id]
  db_subnet_group_name   = aws_db_subnet_group.my_db_public_subnet_group.name
  storage_encrypted      = false
  skip_final_snapshot    = true
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  identifier          = "muaurorainstance"
  cluster_identifier  = aws_rds_cluster.aurorards.id
  instance_class      = "db.t4g.medium"
  engine              = aws_rds_cluster.aurorards.engine
  engine_version      = aws_rds_cluster.aurorards.engine_version
  publicly_accessible = true
}