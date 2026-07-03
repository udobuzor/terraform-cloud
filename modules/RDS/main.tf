resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group"
  subnet_ids = [var.private_subnets[2], var.private_subnets[3]]

  tags = merge(var.tags, { Name = "rds-subnet-group" })
}

resource "aws_db_instance" "rds" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "oddsharedb"
  username               = var.master_username
  password               = var.master_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [var.datalayer_sg_id]
  multi_az               = true
}


