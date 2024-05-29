resource "random_string" "password" {
  length  = 33
  special = false
}

variable "projectsprint_teams" {
  type = map(object({
    start_ecs = bool
    turbo_ecs = bool
  }))
  default = {
    // name should satisfy regular expression '(?:[a-z0-9]+(?:[._-][a-z0-9]+)*/)*[a-z0-9]+(?:[._-][a-z0-9]+)*'
    "testuser2" = { start_ecs = true, turbo_ecs = false }
  }
}

// https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-user#outputs
module "projectsprint_iam_account" {
  for_each = var.projectsprint_teams
  source   = "terraform-aws-modules/iam/aws//modules/iam-user"

  version = "5.33.0"

  name = "projectsprint-${each.key}"

  force_destroy                 = true
  create_iam_user_login_profile = true
  password_length               = 8
  password_reset_required       = false
}


resource "aws_iam_group" "projectsprint_developers" {
  name = "projectsprint-developers"
  path = "/projectsprint_developers/"
}

resource "aws_iam_group_membership" "projectsprint_team" {
  name  = "projectsprint-team"
  users = [for account in module.projectsprint_iam_account : account.iam_user_name]
  group = aws_iam_group.projectsprint_developers.name
}

