# Terraform RDS Deployment

## Description
This project uses Terraform to deploy AWS RDS (PostgreSQL) in a secure VPC environment. The entire infrastructure is organized into modules for better scalability and reusability.


## Terraform Configuration
Before running Terraform, create a `terraform.tfvars` file in the root of the project and add:

```hcl
db_password = "your_password"

Or use an environment variable:

export TF_VAR_db_password="your_password"
The terraform.tfvars file is included in .gitignore to prevent sensitive data from being committed to the repository.
```



## Project Structure
```├── README.md
├── check_task.sh
├── main.tf
├── modules
│   ├── alb
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── ec2
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── ecs
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── rds
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── sg
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── ssh
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
└── variables.tf
```

## Infrastructure Deployment

### 1. Initialize Terraform
```sh
terraform init
```

### 2. Plan Changes
```sh
terraform plan
```

### 3. Apply Configuration
```sh
terraform apply -auto-approve
```

### 4. Retrieve Output Data
```sh
terraform output
```

## Managing ECS
### List Clusters
```sh
aws ecs list-clusters
```

### Retrieve Service Information
```sh
aws ecs describe-services --cluster my-ecs-cluster --services web-service
```
### List Tasks
```sh
aws ecs list-tasks --cluster my-ecs-cluster --query "taskArns" --output table
```

### Describe Tasks
```sh
aws ecs describe-tasks --cluster my-ecs-cluster --tasks <taskArns>
```

### Update Service
```sh
aws ecs update-service --cluster my-ecs-cluster --service web-service --force-new-deployment --enable-execute-command
```
### Exec Service 
```sh
aws ecs execute-command --cluster my-ecs-cluster --task <task_id>  --container nginx-container --command "/bin/bash" --interactive
```


