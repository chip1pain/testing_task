variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS service"
  type        = list(string)
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group for ECS tasks."
}
variable "ecs_execution_role" {
  description = "ARN of the ECS execution role"
  type        = string
}

variable "ecs_task_role" {
  description = "ARN of the ECS task role"
  type        = string
}
