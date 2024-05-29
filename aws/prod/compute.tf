module "nanda-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.1"

  name   = "wireshark-sg"
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
    },
  ]
}

resource "aws_instance" "nanda_instance" {
  ami                         = "ami-034dd93fb26e1a731"
  instance_type               = "t2.nano"
  subnet_id                   = module.default-vpc.default_security_group_id
  key_name                    = data.aws_key_pair.nanda.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    module.nanda-sg.security_group_id
  ]

  tags = {
    Name = "nanda_instance"
  }
}

module "projectsprint_50051_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.1"

  name   = "projectsprint-50051-sg"
  vpc_id = module.default-vpc.default_vpc_id

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 50051
      to_port     = 50051
      protocol    = "tcp"
      description = "Inbound gRPC ProjectSprint TCP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

module "projectsprint_ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.1"

  name   = "projectsprint-ssh-sg"
  vpc_id = module.default-vpc.default_vpc_id

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = [
    "ssh-tcp"
  ]
}
module "projectsprint_8080_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.1"

  name   = "projectsprint-8080-sg"
  vpc_id = module.default-vpc.default_vpc_id

  ingress_rules = [
    "ssh-tcp"
  ]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Inbound ProjectSprint TCP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

resource "aws_instance" "project_sprint_instance" {
  count                       = var.projectsprint_start_load_test ? 1 : 0
  ami                         = "ami-034dd93fb26e1a731"
  instance_type               = "t3a.medium"
  subnet_id                   = data.aws_subnet.b.id
  key_name                    = aws_key_pair.project_sprint[0].key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    module.projectsprint_8080_sg.security_group_id
  ]

  tags = {
    Name = "project_sprint_instance"
  }
}
