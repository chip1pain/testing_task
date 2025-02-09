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


