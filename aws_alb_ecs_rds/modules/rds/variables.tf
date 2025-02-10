variable "db_subnet_group_name" {
  type        = string
  description = "Name of the DB subnet group"
}
variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the RDS instance"
}
variable "security_group_id" {
  type        = string
  description = "Security Group ID"
}


variable "db_name" {
  type        = string
  description = "Название базы данных"
}

variable "db_username" {
  type        = string
  description = "Имя пользователя для БД"
}

variable "db_password" {
  type        = string
  description = "Пароль для БД"
  sensitive   = true
}
