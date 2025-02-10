resource "aws_db_subnet_group" "db_subnet_group" {
  name        = var.db_subnet_group_name
  subnet_ids  = var.subnet_ids
  description = "Database subnet group"
}

resource "aws_db_instance" "postgres_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "17"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name  
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name  
  vpc_security_group_ids = [var.security_group_id]
  multi_az             = false
  publicly_accessible  = false
  skip_final_snapshot  = true 
}
