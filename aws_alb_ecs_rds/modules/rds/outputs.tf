output "db_instance_id" {
  value = aws_db_instance.postgres_db.id
}

output "db_endpoint" {
  value = aws_db_instance.postgres_db.endpoint
}

output "db_name" {
  value       = aws_db_instance.postgres_db.db_name
  description = "Database name"
}

output "db_user" {
  value       = aws_db_instance.postgres_db.username
  description = "Database username"
}
