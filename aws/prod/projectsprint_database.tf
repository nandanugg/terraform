resource "aws_db_instance" "projectsprint_ecs_db" {
  count = var.projectsprint_start_db ? 1 : 0

  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "16.1"  
  instance_class       = "db.t3.micro"
  identifier           = "projectsprint-db"
  username             = "postgres"
  password             = "meeCoemengu5biY7peigahshiejaiv1ae" 
  parameter_group_name = "default.postgres16"  
  skip_final_snapshot  = true
  
  storage_encrypted = false
  deletion_protection = false

  vpc_security_group_ids = [aws_security_group.projectsprint_ecs_db_sg.id]  
  db_subnet_group_name   = aws_db_subnet_group.projectsprint_ecs_subnet_group.name  

  tags = {
    Name = "projectsprint-db"
  }
}


resource "aws_db_subnet_group" "projectsprint_ecs_subnet_group" {
  name       = "projectsprint-ecs-subnet-group"
  subnet_ids = [var.subnet_1a, var.subnet_1b]
}

resource "aws_security_group" "projectsprint_ecs_db_sg" {
  name_prefix = "projectsprint-ecs-db-sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust based on your security requirements
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "projectsprint_ecs_mesh_sg" {
  name_prefix = "projectsprint-ecs-db-sg"

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}