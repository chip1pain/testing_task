# Terraform RDS Deployment

## Description
This project uses Terraform to deploy AWS RDS (PostgreSQL) in a secure VPC environment. The entire infrastructure is organized into modules for better scalability and reusability.

## Project Structure
```
terraform/
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── rds/
│   ├── ecs/
│   ├── eks/
│   ├── alb/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
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

## Managing RDS
### Retrieve Database Information
```sh
aws rds describe-db-instances --query "DBInstances[*].{ID:DBInstanceIdentifier, Status:DBInstanceStatus, Endpoint:Endpoint.Address}"
```

### Create a Database Snapshot
```sh
aws rds create-db-snapshot --db-instance-identifier <db-instance-id> --db-snapshot-identifier <snapshot-name>
```

### Restore from Snapshot
```sh
aws rds restore-db-instance-from-db-snapshot --db-instance-identifier <new-db-instance-id> --db-snapshot-identifier <snapshot-name>
```

## Managing EC2
### Retrieve Public IP of an Instance
```sh
terraform output public_ip
```

### Connect via SSH
```sh
ssh -i ~/nginx/private_key.pem ubuntu@<public_ip>
```

## Managing ECS
### List Clusters
```sh
aws ecs list-clusters --query "clusterArns" --output table
```

### Retrieve Service Information
```sh
aws ecs describe-services --cluster my-ecs-cluster --services web-service
```

### Update Service
```sh
aws ecs update-service --cluster my-ecs-cluster --service web-service --force-new-deployment --enable-execute-command
```

## Managing EKS
### List EKS Clusters
```sh
aws eks list-clusters --query "clusters" --output table
```

### Retrieve Cluster Details
```sh
aws eks describe-cluster --name my-eks-cluster
```

## Managing ALB
### Retrieve List of Target Groups
```sh
aws elbv2 describe-target-groups --query 'TargetGroups[*].TargetGroupArn'
```

### Delete Target Group
```sh
aws elbv2 delete-target-group --target-group-arn <target-group-arn>
```

## Tear Down Infrastructure
### Destroy Infrastructure
```sh
terraform destroy -auto-approve
```

## AWS CLI Commands Reference

### EC2 (Elastic Compute Cloud)
#### Instances
- `aws ec2 run-instances` — create a new EC2 instance.
- `aws ec2 describe-instances` — describe instances.
- `aws ec2 terminate-instances` — terminate an instance.
- `aws ec2 start-instances` — start an instance.
- `aws ec2 stop-instances` — stop an instance.
#### Security Groups
- `aws ec2 describe-security-groups` — describe all security groups.
- `aws ec2 create-security-group` — create a new security group.
- `aws ec2 authorize-security-group-ingress` — add ingress rules.
- `aws ec2 revoke-security-group-ingress` — remove ingress rules.
#### Key Pairs
- `aws ec2 describe-key-pairs` — list available SSH keys.
- `aws ec2 create-key-pair` — create a new SSH key.

### ECS (Elastic Container Service)
#### Cluster Management
- `aws ecs create-cluster` — create an ECS cluster.
- `aws ecs describe-clusters` — describe ECS clusters.
#### Task Definitions
- `aws ecs register-task-definition` — register a new Task Definition.
- `aws ecs describe-task-definition` — describe Task Definition.
#### Services
- `aws ecs create-service` — create an ECS service.
- `aws ecs update-service` — update an ECS service.
- `aws ecs delete-service` — delete an ECS service.
#### Running Tasks
- `aws ecs run-task` — run tasks on ECS.

### RDS (Relational Database Service)
#### Instances
- `aws rds create-db-instance` — create a new database instance.
- `aws rds describe-db-instances` — describe all RDS instances.
- `aws rds delete-db-instance` — delete a database instance.
#### DB Subnet Group
- `aws rds create-db-subnet-group` — create a DB subnet group.
- `aws rds describe-db-subnet-groups` — describe subnet groups.
#### Backup and Snapshot
- `aws rds create-db-snapshot` — create a database snapshot.
- `aws rds describe-db-snapshots` — list all database snapshots.

### VPC (Virtual Private Cloud)
#### VPC Management
- `aws ec2 create-vpc` — create a VPC.
- `aws ec2 describe-vpcs` — describe VPCs.
#### Subnets
- `aws ec2 create-subnet` — create a subnet.
- `aws ec2 describe-subnets` — describe subnets.
#### Internet Gateway
- `aws ec2 create-internet-gateway` — create an internet gateway.
- `aws ec2 describe-internet-gateways` — describe internet gateways.
#### Route Tables
- `aws ec2 create-route-table` — create a route table.
- `aws ec2 describe-route-tables` — describe route tables.
#### NAT Gateway
- `aws ec2 create-nat-gateway` — create a NAT gateway.
- `aws ec2 describe-nat-gateways` — describe NAT gateways.

### IAM (Identity and Access Management)
#### Users
- `aws iam create-user` — create a new IAM user.
- `aws iam list-users` — list all users.
#### Policies
- `aws iam create-policy` — create a new policy.
- `aws iam list-policies` — list policies.
#### Roles
- `aws iam create-role` — create a new role.
- `aws iam list-roles` — list roles.

### CloudWatch
#### Log Groups
- `aws logs create-log-group` — create a log group.
- `aws logs describe-log-groups` — list all log groups.
#### Alarms
- `aws cloudwatch put-metric-alarm` — create an alarm.
- `aws cloudwatch describe-alarms` — describe alarms.

### S3 (Simple Storage Service)
#### Buckets
- `aws s3 mb s3://bucket-name` — create a new bucket.
- `aws s3 ls` — list all buckets.
#### Objects
- `aws s3 cp` — copy objects.
- `aws s3 rm` — delete objects.

### Lambda
#### Functions
- `aws lambda create-function` — create a new Lambda function.
- `aws lambda invoke` — invoke a Lambda function.
- `aws lambda update-function-code` — update function code.

### ALB (Application Load Balancer)
#### Load Balancers
- `aws elbv2 create-load-balancer` — create an ALB.
- `aws elbv2 describe-load-balancers` — describe all ALBs.
#### Target Groups
- `aws elbv2 create-target-group` — create a target group.
- `aws elbv2 describe-target-groups` — describe target groups.


