# output "private_key" {
#   value = module.ssh.private_key
#   sensitive = true
# }

# output "key_name" {
#   value = module.ssh.key_name
# }

# output "public_ip" {
#   value = module.ec2.public_ip
#   description = "Public IP of the EC2 instance"
# }

output "rds_db_instance_id" {
  value = module.rds.db_instance_id
}

output "rds_db_endpoint" {
  value = module.rds.db_endpoint
}

output "rds_db_name" {
  value = module.rds.db_name
}

output "rds_db_username" {
  value = module.rds.db_user
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}


