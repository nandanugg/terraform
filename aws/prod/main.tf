#          ╭──────────────────────────────────────────────────────────╮
#          │                        NETWORKING                        │
#          ╰──────────────────────────────────────────────────────────╯
module "default-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  create_vpc = false

  manage_default_vpc = true
  default_vpc_name   = "default"
}

module "app-ec2-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.1"

  name   = "ec2-sg"
  vpc_id = module.default-vpc.default_vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 58211
      to_port     = 58211
      protocol    = "tcp"
      description = "Inbound Wireshark TCP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 58211
      to_port     = 58211
      protocol    = "udp"
      description = "Inbound Wireshark UDP"
      cidr_blocks = "0.0.0.0/0"
    }
    # {
    #   from_port   = 21
    #   to_port     = 21
    #   protocol    = "tcp"
    #   description = "Inbound FTP TCP"
    #   cidr_blocks = ["0.0.0.0/0"]
    # },
    # {
    #   from_port   = 21
    #   to_port     = 21
    #   protocol    = "udp"
    #   description = "Inbound FTP UDP"
    #   cidr_blocks = ["0.0.0.0/0"]
    # },
  ]
}
#          ╭──────────────────────────────────────────────────────────╮
#          │                           IAM                            │
#          ╰──────────────────────────────────────────────────────────╯

module "s3-user" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.33.0"

  name                          = "sprint-s3-user"
  force_destroy                 = true
  create_iam_user_login_profile = false
  policy_arns = [
    module.s3-user-policy.arn
  ]
}

module "s3-user-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "sprint-s3-user-policy"
  path = "/"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:List*",
            "s3:Get*",
            "s3:Put*",
            "s3:DeleteObject*",
            "s3:CreateSession*",
          ]
          Resource = ["arn:aws:s3:::sprint-bucket-public-read/*", "arn:aws:s3:::sprint-bucket-public-read"]
        }
      ]
    }
  )
}

#          ╭──────────────────────────────────────────────────────────╮
#          │                         COMPUTE                          │
#          ╰──────────────────────────────────────────────────────────╯
resource "aws_instance" "nanda_big_instance" {
  count                       = var.create_server ? 1 : 0
  ami                         = "ami-034dd93fb26e1a731"
  instance_type               = "t2.medium"
  subnet_id                   = module.default-vpc.default_security_group_id
  key_name                    = data.aws_key_pair.nanda.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    module.app-ec2-sg.security_group_id
  ]

  tags = {
    Name = "nanda_big_instance"
  }
}

#          ╭──────────────────────────────────────────────────────────╮
#          │                      OBJECT STORAGE                      │
#          ╰──────────────────────────────────────────────────────────╯
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket            = "sprint-bucket-public-read"
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  acl = "public-read"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  lifecycle_rule = [
    {
      id      = "expired_all_files"
      enabled = true
      expiration = {
        days = 1
      }
    }
  ]
}
