# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "default-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  create_vpc = false

  manage_default_vpc = true
  default_vpc_name   = "default"
}

data "aws_subnet" "a" {
  id = var.subnet_1a
}
data "aws_subnet" "b" {
  id = var.subnet_1b
}
data "aws_subnet" "c" {
  id = var.subnet_1c
}
