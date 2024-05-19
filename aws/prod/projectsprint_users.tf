resource "random_string" "password" {
  length  = 33
  special = false
}

variable "projectsprint_teams" {
  type = map(object({
    run_ecs = bool
    turbo   = bool
    db_pass = string
  }))
  default = {
    "agusheryanto182" = { run_ecs = true, turbo = false, db_pass = "cei4gahngeiThaexeeLie6nohxe8cheiN" }
    "alfanzainkp"     = { run_ecs = false, turbo = false, db_pass = "" }
    "alrasyidlathif"  = { run_ecs = true, turbo = false, db_pass = "iaDahr6Sieshimiexei9Paeg8Thof8cai" }
    "asadulhaqmshani" = { run_ecs = false, turbo = false, db_pass = "" }
    "backendmagang"   = { run_ecs = true, turbo = true, db_pass = "ooquap3sho0luabooy2cheeche1xeKath" }
    "bennoalif"       = { run_ecs = false, turbo = false, db_pass = "" }
    "chalk93"         = { run_ecs = false, turbo = false, db_pass = "" }
    "dionedo"         = { run_ecs = false, turbo = false, db_pass = "" }
    "dwibi"           = { run_ecs = false, turbo = false, db_pass = "" }
    "enigmanations"   = { run_ecs = true, turbo = false, db_pass = "chooh3Cuuphoow8waew5eun0up1ohzee3" }
    "inmydream"       = { run_ecs = true, turbo = false, db_pass = "eic3eeR5aec1Aez0EeThao4at0choh6Be" }
    "iwasbornalone"   = { run_ecs = true, turbo = true, db_pass = "eg1xiegh9fahkoh8alo0Aehomu4vootoh" }
    "j03hanafi"       = { run_ecs = true, turbo = true, db_pass = "quooy9shiLeesohjaeBieyoox8ThahBoo" }
    "jessenicholast"  = { run_ecs = true, turbo = true, db_pass = "phes1shaeDoPeeR4Oo6FahghaeT9tee4D" }
    "kangman53"       = { run_ecs = true, turbo = true, db_pass = "Eekeey0Pachoos7Thaipiengieniesai4" }
    "lingstr246"      = { run_ecs = false, turbo = false, db_pass = "" }
    "m_ulil_azmi"     = { run_ecs = true, turbo = false, db_pass = "po9euch3Wioziet5ool1yiyi3Fuep4tei" }
    "motifakes"       = { run_ecs = false, turbo = false, db_pass = "" }
    "mraskaa"         = { run_ecs = false, turbo = false, db_pass = "" }
    "pinginciuman"    = { run_ecs = true, turbo = false, db_pass = "wiesoroshieY9vai1Chahcoogahqu6Eeb" }
    "recholup"        = { run_ecs = true, turbo = true, db_pass = "ahpoo4loh6Au8oow9eexi1wieThahl2ai" }
    "shamirhusein"    = { run_ecs = true, turbo = true, db_pass = "dohS6Xiuk1au7oHee1EXiechuo7ohng1o" }
    "syarif_04"       = { run_ecs = true, turbo = true, db_pass = "yeiyei2dei0Lo1tooZezei2Zeefoozeph" }
    "tablestanding"   = { run_ecs = false, turbo = false, db_pass = "" }
    "testuser"        = { run_ecs = true, turbo = false, db_pass = "etea4iengu5La0eZohsah2je7yeidieko" }
    "thesagab"        = { run_ecs = true, turbo = true, db_pass = "feyaa4oiPh8UC9ieh0jae7iephooTa7ie" }
    "thorumr"         = { run_ecs = true, turbo = false, db_pass = "ziequ8thubaiYee0Jaesah8xi8shoo6ee" }
    "txtdarisugab"    = { run_ecs = true, turbo = true, db_pass = "tahphee9ogh1aiMaivoogaengiebeo9zu", }
    "ubigantung"      = { run_ecs = true, turbo = true, db_pass = "oVaen4neutheita1ivach6aeheexaeLow" }
    "umar_a3"         = { run_ecs = true, turbo = false, db_pass = "ahqueequ8goom0ahJ5Iegh4cou1eefoh8" }
    "vinsskyy"        = { run_ecs = false, turbo = false, db_pass = "" }
    "ydesetiawan94"   = { run_ecs = true, turbo = true, db_pass = "ooVahzoaj4veezahl6kuRaif5pee3Iej2" }
    "yuhuyuhuuya"     = { run_ecs = false, turbo = false, db_pass = "" }
    "arsyopraza"      = { run_ecs = false, turbo = false, db_pass = "aejaeY2ohRaiku7ju4wahs0rigee4iePh" }
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

