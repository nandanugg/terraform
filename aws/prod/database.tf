# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest
module "projectsprint-db-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.1"

  name   = "projectsprint-db-sg"
  vpc_id = module.default-vpc.default_vpc_id

#   ingress_rules       = [""]
#   ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Inbound ProjectSprint Postgres DB TCP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}
# https://registry.terraform.io/modules/terraform-aws-modules/rds/aws/latest
# https://ap-southeast-1.console.aws.amazon.com/secretsmanager/listsecrets?region=ap-southeast-1
module "projectsprint-db" {
  count = var.projectsprint_start ? 1 : 0
  source = "terraform-aws-modules/rds/aws"
  version = "6.5.2"

  identifier = "projectsprint-db"

  engine            = "postgres"
  engine_version    = "16.1"
  # aws rds describe-orderable-db-instance-options --engine postgres --engine-version 16.1 --region $AWS_REGION --output json --query 'OrderableDBInstanceOptions[*].{DBInstanceClass:DBInstanceClass,EngineVersion:EngineVersion,MinStorageSize:MinStorageSize}' 
  instance_class    = "db.t3.micro"
  allocated_storage = 5 # in GB

  db_name  = "postgres"
  username = "postgres"
  port     = "5432"

  iam_database_authentication_enabled = false
  manage_master_user_password = false
  password = var.projectsprint_db_password

  vpc_security_group_ids = [module.projectsprint-db-sg.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  publicly_accessible = true

  # todo: IAM DB authentication true

  tags = {
    Owner       = "projectsprint"
    Environment = "test"
  }

  # DB subnet group
  subnet_ids = [data.aws_subnet.a.id, data.aws_subnet.b.id]

  # DB parameter group
  # aws rds describe-db-engine-versions --query "DBEngineVersions[].DBParameterGroupFamily" | grep "postgres"
  family = "postgres16"

  # DB option group
  # aws rds describe-db-engine-versions --region $AWS_REGION --output json  --query "DBEngineVersions[?Engine=='postgres'].{Engine:Engine,EngineVersion:EngineVersion}"
  major_engine_version = "16.1"

  # Database Deletion Protection
  deletion_protection = false
}
