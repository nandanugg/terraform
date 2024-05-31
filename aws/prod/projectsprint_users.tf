resource "random_string" "password" {
  length  = 33
  special = false
}

variable "projectsprint_teams" {
  type = map(object({
    start_ecs       = bool
    turbo_ecs       = bool
    independent_ecs = bool
  }))
  default = {
    // name should satisfy regular expression '(?:[a-z0-9]+(?:[._-][a-z0-9]+)*/)*[a-z0-9]+(?:[._-][a-z0-9]+)*'
    "thorumr"         = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "chalk93"         = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "dionedo"         = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "raf_encoding"    = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "agusheryanto182" = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "syarif_04"       = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "recholup"        = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "m_ulil_azmi"     = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "thesagab"        = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "ilhamsurya_m"    = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "jessenicholast"  = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "vinsskyy"        = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "ydesetiawan94"   = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "inmydream"       = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "j03hanafi"       = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "iwasbornalone"   = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "ilhamsurya_m"    = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "shamirhusein"    = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "enigmanations"   = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "danimron"        = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "ubigantung"      = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "dwibi"           = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "alrasyidlathif"  = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "yuhuyuhuuya"     = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "lingstr246"      = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
    "testuser"        = { start_ecs = false, turbo_ecs = false, independent_ecs = true }
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

