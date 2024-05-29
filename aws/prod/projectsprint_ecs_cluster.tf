resource "aws_ecs_cluster" "projectsprint" {
  count = var.projectsprint_start_ecs_cluster ? 1 : 0
  name  = "projectsprint"
}

resource "aws_service_discovery_private_dns_namespace" "projectsprint" {
  name        = "projectsprint.local"
  description = "Private DNS namespace for projectsprint"
  vpc         = module.default-vpc.default_vpc_id
}
