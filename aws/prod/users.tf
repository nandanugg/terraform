data "aws_iam_user" "current_user" {
  user_name = "nanda_console"
}

data "aws_caller_identity" "current" {}
