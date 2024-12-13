# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

# output "aws_availability_zones" {
#    description = "Value"
#    value = data.aws_availability_zones.*
# } 

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "loadbalancer_dns_name" {
  value = data.kubernetes_service.logstashUrl.status[0].load_balancer[0].ingress[0]
}