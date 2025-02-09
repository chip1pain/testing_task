
# Переменные
variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_1" {
  type        = string
  description = "CIDR block for the first public subnet"
}

variable "public_subnet_cidr_2" {
  type        = string
  description = "CIDR block for the second public subnet"
}

variable "private_subnet_cidr_1" {
  type        = string
  description = "CIDR block for the first private subnet"
}

variable "private_subnet_cidr_2" {
  type        = string
  description = "CIDR block for the second private subnet"
}

variable "availability_zone_1" {
  type        = string
  description = "First Availability Zone (e.g., us-east-1a)"
}

variable "availability_zone_2" {
  type        = string
  description = "Second Availability Zone (e.g., us-east-1b)"
}
