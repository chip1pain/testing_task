# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_subnet" {
  description = "vpc subnet"
  type        = string
  default     = "10.0.0.0/16"
}


variable "private_key_path" {
  description = "/Users/red/nginx/nginx_key"
  type        = string
  default     = "~/nginx/nginx_key"
}


variable "python_script" {
  description = "python_script"
  type        = string
  default     = "/Users/red/workspace/testing_task/python_resource_monitor"
}