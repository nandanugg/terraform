locals {
  # Number of teams
  team_count = length(var.projectsprint_teams)

  # CPU and memory per container (in units)
  cpu_per_container    = 2048  # 2 vCPU
  memory_per_container = 4096  # 4 GB

  # Number of containers per team
  containers_per_team = 3

  # Total CPU and memory per team
  total_cpu_per_team    = local.cpu_per_container * local.containers_per_team
  total_memory_per_team = local.memory_per_container * local.containers_per_team

  # Total CPU and memory for all teams
  total_cpu    = local.total_cpu_per_team * local.team_count
  total_memory = local.total_memory_per_team * local.team_count
}
