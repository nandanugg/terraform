module "default-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  create_vpc = false

  manage_default_vpc = true
  default_vpc_name   = "default"
}
