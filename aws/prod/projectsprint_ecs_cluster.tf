resource "aws_ecs_cluster" "projectsprint_cluster" {
  count = var.projectsprint_start_ecs ? 1 : 0
  name = "projectsprint-cluster"
}

resource "aws_service_discovery_private_dns_namespace" "projectsprint_dns_namespace" {
  name        = "projectsprint.local"
  description = "Private DNS namespace for projectsprint"
  vpc         = module.default-vpc.default_vpc_id
}