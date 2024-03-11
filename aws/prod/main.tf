terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_subnet" "default" {
  id = var.subnet_id_default
}

variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "default region"
}

variable "vpc_id" {
  type        = string
  default     = "vpc-0ec5b8b73405bbf65"
  description = "default vpc id"
}

variable "subnet_id_default" {
  type        = string
  default     = "subnet-090fe3939c3fd853a"
  description = "default subnet id"
}
