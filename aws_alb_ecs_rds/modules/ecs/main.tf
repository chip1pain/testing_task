resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "web-task"
  network_mode             = "awsvpc"  # Для Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role
  task_role_arn            = var.ecs_task_role


  container_definitions = jsonencode([{
    name      = "nginx-container"
    image     = "nginx:latest"
    essential = true

    command   = [
      "sh", "-c",
      "apt-get update && apt-get install -y fortune postgresql-client && /usr/games/fortune > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"
    ]
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])
}
resource "aws_ecs_service" "ecs_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  enable_execute_command = true
  
  network_configuration {
    subnets          = var.subnet_ids  # Список подсетей для ECS
    security_groups  = [var.security_group_id]
    assign_public_ip = false  # Присваиваем публичные IP контейнерам
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nginx-container"
    container_port   = 80
  }

  depends_on = [
    aws_ecs_task_definition.task_definition
  ]
}


