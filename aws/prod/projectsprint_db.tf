resource "aws_db_instance" "projectsprint_ecs_db" {
  for_each = {
    for team, config in var.projectsprint_teams :
    team => config if config.start_ecs
  }

  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "16.1"
  instance_class       = "db.t3.micro"
  identifier           = "projectsprint-${each.key}-db"
  username             = "postgres"
  password             = random_string.db_pass[each.key].result
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true

  storage_encrypted   = false
  deletion_protection = false

  vpc_security_group_ids = [aws_security_group.projectsprint_ecs_db.id]
  db_subnet_group_name   = aws_db_subnet_group.projectsprint_ecs_db.name

  tags = {
    Name = "projectsprint-${each.key}-db"
  }
}

resource "aws_db_subnet_group" "projectsprint_ecs_db" {
  name       = "projectsprint-ecs"
  subnet_ids = [var.subnet_1a, var.subnet_1b]
}

resource "aws_security_group" "projectsprint_ecs_db" {
  name_prefix = "projectsprint-ecs-db"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust based on your security requirements
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_string" "db_pass" {
  for_each = {
    for team, config in var.projectsprint_teams :
    team => config if config.start_ecs
  }
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}
