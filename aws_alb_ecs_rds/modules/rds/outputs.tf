output "db_instance_id" {
  value = aws_db_instance.postgres_db.id
}

output "db_endpoint" {
  value = aws_db_instance.postgres_db.endpoint
}
