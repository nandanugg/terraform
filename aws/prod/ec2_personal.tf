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