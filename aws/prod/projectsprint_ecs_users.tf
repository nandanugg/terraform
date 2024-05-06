variable projectsprint_teams {
  type        = list(string)
  default     = [
    # "ahmednroll",
    # "testuser",
    # "arfan",
    # "billymosis",
    # "diaz-agfa",
    # "garfieldzero",
    # "hiiamninna",
    # "ilhamnyto",
    # "kasjful-kurniawan",
    # "kntlmas",
    # "nailanmnabil",
    # "nasgorsifudd",
    # "shafa-alafghany",
    # "tango-redox",
    # "the-sagab",
    # "veidroz"
  ]
  # default = []
}

module "ecs_ecr_user_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "ecs-ecr-manage-policy"
  path = "/"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:*",
            "ecs:*",
            "iam:ChangePassword",
            "servicediscovery:ListNamespaces",
            "cloudformation:CreateStack",
            "iam:ListRoles",
            "iam:PassRole",
            "logs:DescribeLogGroups",
            "logs:CreateLogGroup",
          ]
          Resource = "*"
        }
      ]
    }
  )
}

resource "aws_iam_role" "projectsprint_ecs_task_execution_role" {
  name = "projectsprint_ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.projectsprint_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "projectsprint_ecs_task_role" {
  name = "projectsprint_ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

# resource "aws_iam_policy" "ecs_task_custom_policy" {
#   name        = "ecs_task_custom_policy"
#   description = "A test policy for ECS tasks"
#   policy      = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:ListBucket"
#       ],
#       "Resource": ["arn:aws:s3:::your_bucket_name"]
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_custom_policy_attachment" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.ecs_task_custom_policy.arn
# }

resource "aws_iam_policy" "ecs_slr_creation_policy" {
  name        = "ECS_ServiceLinkedRole_CreationPolicy"
  description = "Policy to allow creation of Service Linked Role for ECS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "logs:GetLogEvents",
        "cloudformation:DescribeStacks",
        "cloudformation:DescribeStackEvents",
        "ec2:DescribeNetworkInterfaces"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "ecs_slr_creation_user_attachment" {
  for_each   = module.projectsprint_iam_account
  user       = each.value.iam_user_name
  policy_arn = aws_iam_policy.ecs_slr_creation_policy.arn
}

module "projectsprint_iam_account" {
  for_each = toset(var.projectsprint_teams)
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  
  version = "5.33.0"

  name = "projectsprint-${each.value}"

  force_destroy                 = true
  create_iam_user_login_profile = true
  password_length = 8
  password_reset_required = false

  policy_arns = [
    module.ecs_ecr_user_policy.arn
  ]
}
