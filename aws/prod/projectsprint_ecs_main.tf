module "projectsprint_ecs_cluster" {
  count = var.projectsprint_start_ecs ? 1 : 0
  source = "terraform-aws-modules/ecs/aws"
  
  cluster_name = "projectsprint-cluster"

  tags = {
    Environment = "Development"
  }
}

resource "aws_service_discovery_private_dns_namespace" "projectsprint_dns_namespace" {
  name        = "projectsprint.local"
  description = "Private DNS namespace for projectsprint"
  vpc         = module.default-vpc.default_vpc_id
}