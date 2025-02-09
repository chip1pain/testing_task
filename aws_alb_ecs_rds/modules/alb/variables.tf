variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnets for the ALB"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for ALB"
}

