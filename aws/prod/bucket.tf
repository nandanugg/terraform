
module "s3-user" {
  count = var.projectsprint_start ? 1 : 0
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.33.0"

  name                          = "sprint-s3-user"
  force_destroy                 = true
  create_iam_user_login_profile = false
  policy_arns = [
    module.s3-user-policy.arn
  ]
}

module "s3-user-policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "sprint-s3-user-policy"
  path = "/"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:List*",
            "s3:Get*",
            "s3:Put*",
            "s3:DeleteObject*",
            "s3:CreateSession*",
          ]
          Resource = ["arn:aws:s3:::sprint-bucket-public-read/*", "arn:aws:s3:::sprint-bucket-public-read"]
        }
      ]
    }
  )
}

# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "s3-bucket" {
  # count = var.projectsprint_start ? 1 : 0
  count = false ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket            = "sprint-bucket-public-read"
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  acl = "public-read"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  lifecycle_rule = [
    {
      id      = "expired_all_files"
      enabled = true
      expiration = {
        days = 1
      }
    }
  ]
}
