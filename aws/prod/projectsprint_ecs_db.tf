resource "aws_service_discovery_service" "projectsprint_ecs_db_service_discovery" {
  for_each = {
    for team, config in var.projectsprint_teams :
    team => config if config.run_ecs
  }
  name = "${each.key}_db"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.projectsprint_dns_namespace.id

    dns_records {
      type = "A"
      ttl  = 10
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
  force_destroy = true
}

resource "aws_ecs_service" "projectsprint_ecs_db_service" {
  for_each = {
    for team, config in var.projectsprint_teams :
    team => config if config.run_ecs
  }
  name            = "projectsprint-${each.key}-db-service"
  cluster         = module.projectsprint_ecs_cluster[0].cluster_arn
  task_definition = aws_ecs_task_definition.projectsprint_ecs_db_task_definition[each.key].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet_1a]
    security_groups  = [
      aws_security_group.projectsprint_ecs_db_sg.id,
      aws_security_group.projectsprint_ecs_mesh_sg.id
    ]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.projectsprint_ecs_db_service_discovery[each.key].arn
  }
}

resource "aws_ecs_task_definition" "projectsprint_ecs_db_task_definition" {
  for_each = {
    for team, config in var.projectsprint_teams :
    team => config if config.run_ecs
  }
  family                   = "projectsprint-${each.key}-db-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = each.value.turbo ? 2048 : 1024
  memory                   = each.value.turbo ? 4096 : 2048
  execution_role_arn       = aws_iam_role.projectsprint_ecs_task_execution_service_role.arn
  task_role_arn      = aws_iam_role.projectsprint_ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${each.key}-db-container"
      image     = "postgres:16.3-alpine3.19"
      cpu       = each.value.turbo ? 2048 : 1024
      memory    = each.value.turbo ? 4096 : 2048
      essential = true
      portMappings = [
        {
          containerPort = 5432
          hostPort      = 5432
        }
      ]
      environment = [
        { "name" : "POSTGRES_PASSWORD", "value" : each.value.db_pass },
        { "name" : "POSTGRES_DB", "value" :  "postgres" },
        { "name" : "POSTGRES_USER", "value" : "postgres" },
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.projectsprint_db_service[each.key].name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    },
  ])
  depends_on = [ 
  ]
}

resource "aws_cloudwatch_log_group" "projectsprint_db_service" {
  for_each = { 
    for team, config in var.projectsprint_teams : 
    team => config if config.run_ecs 
  }
  name              = "/ecs/db/projectsprint-${each.key}"
  retention_in_days = 7
}
