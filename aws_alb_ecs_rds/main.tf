module "vpc" {
  source                = "./modules/vpc"
  cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_1  = "10.0.1.0/24"
  public_subnet_cidr_2  = "10.0.2.0/24"
  private_subnet_cidr_1 = "10.0.3.0/24"
  private_subnet_cidr_2 = "10.0.4.0/24"
  availability_zone_1   = "us-east-1a"
  availability_zone_2   = "us-east-1b"
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "iam" {
  source = "./modules/iam"
}


# module "ssh" {
#   source = "./modules/ssh"  # путь к модулю с SSH-ключом
# }

# module "ec2" {
#   source   = "./modules/ec2"
#   vpc_id   = module.vpc.vpc_id
#   subnet_id = module.vpc.public_subnet_id
#   ami_id   = "ami-0a313d6098716f372"  # Замените на свой AMI
#   security_group_id = module.sg.ecs_sg_id
#   key_name = module.ssh.key_name  
# }


module "ecs" {
  source              = "./modules/ecs"
  subnet_ids          = module.vpc.private_subnet_ids  # Используем приватные подсети для ECS
  security_group_id   = module.sg.ecs_sg_id           # Используем ecs_sg для безопасности
  target_group_arn    = module.alb.target_group_arn 
  ecs_execution_role  = module.iam.ecs_execution_role_arn
  ecs_task_role       = module.iam.ecs_task_role_arn
}

module "rds" {
  source               = "./modules/rds"
  db_subnet_group_name = "my-db-subnet-group"
  subnet_ids           = module.vpc.private_subnet_ids # Это будет список ID приватных подсетей
  security_group_id    = module.sg.rds_sg_id
  db_name              = "mbdb"
  db_username          = "pgadmin"
  db_password          = var.db_password # Лучше передавать как переменную
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnet_ids  # ALB должен быть в публичных подсетях
  security_group_id = module.sg.alb_sg_id  # Используем security group для ALB
}
