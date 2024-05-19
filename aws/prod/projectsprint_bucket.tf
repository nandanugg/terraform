module "projectsprint_s3_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "projectsprint-s3-user-policy"
  path = "/"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:ListAllMyBuckets"
          ]
          Resource = ["*"]
        },
        {
          Effect = "Allow"
          Action = [
            "s3:List*",
            "s3:Get*",
            "s3:Put*",
            "s3:DeleteObject*",
            "s3:CreateSession*",
          ]
          Resource = [module.projectsprint_bucket[0].s3_bucket_arn, "${module.projectsprint_bucket[0].s3_bucket_arn}/*"]
        }
      ]
    }
  )
}

resource "aws_iam_group_policy_attachment" "projectsprint_group_policy_attachment" {
  group       = aws_iam_group.projectsprint_developers.name
  policy_arn = module.projectsprint_s3_policy.arn
}

# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "projectsprint_bucket" {
  # count = var.projectsprint_start ? 1 : 0
  count = true ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"

  bucket            = "projectsprint-bucket-public-read"
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
