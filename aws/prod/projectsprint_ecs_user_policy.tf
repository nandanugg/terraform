module "projectspint_ecs_user_policy" {
  for_each = {
    for team, config in var.projectsprint_teams :
    team => config if config.start_ecs
  }
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "projectspint-ecs-user-policy-${each.key}"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:ListClusters",
          "ecs:ListTaskDefinitionFamilies",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeServices",
          "ecs:ListServices",
          "ecs:ListAccountSettings",
          "cloudwatch:GetMetricData",
          "application-autoscaling:DescribeScalingPolicies",
          "application-autoscaling:DescribeScalableTargets",
          "servicediscovery:GetService",
          "servicediscovery:GetNamespace",
          "servicediscovery:ListNamespaces",
          "ec2:DescribeNetworkInterfaces",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeClusters",
          "ecs:ListContainerInstances"
        ]
        Resource = "${aws_ecs_cluster.projectsprint[0].arn}*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:FilterLogEvents",
          "logs:StartLiveTail",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetQueryResults",
        ]
        Resource = [
          "${aws_cloudwatch_log_group.projectsprint[each.key].arn}*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
        ]
        Resource = [
          "${aws_ecs_service.projectsprint[each.key].id}*",
        ]
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "projectsprint_ecs_user" {
  for_each = {
    for team, config in var.projectsprint_teams :
    team => config if config.start_ecs
  }

  user       = module.projectsprint_iam_account[each.key].iam_user_name
  policy_arn = module.projectspint_ecs_user_policy[each.key].arn
}


module "projectspint_ecs_independent_user_policy" {
  for_each = {
    for team, config in var.projectsprint_teams :
    team => config if config.independent_ecs
  }
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "projectspint-ecs-user-policy-${each.key}"
  path = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:ListClusters",

          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:ListTaskDefinitions",
          "ecs:ListTaskDefinitionFamilies",
          "ecs:DeregisterTaskDefinition",
          "ecs:ListAccountSettings",
          "ecs:RegisterTaskDefinition",

          "ecs:DescribeServices",
          "ecs:ListServices",
          "ecs:UpdateService",
          "ecs:CreateService",
          "ecs:DeleteService",

          "cloudwatch:GetMetricData",

          "cloudformation:CreateStack",

          "application-autoscaling:DescribeScalingPolicies",
          "application-autoscaling:DescribeScalableTargets",

          "servicediscovery:GetService",
          "servicediscovery:GetNamespace",
          "servicediscovery:ListNamespaces",

          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",


          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:DescribeRepositories",
          "ecr:GetRegistryScanningConfiguration",
          "ecr:ListTagsForResource",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:BatchDeleteImage",

          "iam:ListRoles",
          "iam:PassRole",
          "iam:GetRole",

          "logs:FilterLogEvents",
          "logs:StartLiveTail",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetQueryResults",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeClusters",
          "ecs:ListContainerInstances"
        ]
        Resource = "${aws_ecs_cluster.projectsprint[0].arn}*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "projectsprint_ecs_independent_user" {
  for_each = {
    for team, config in var.projectsprint_teams :
    team => config if config.independent_ecs
  }

  user       = module.projectsprint_iam_account[each.key].iam_user_name
  policy_arn = module.projectspint_ecs_independent_user_policy[each.key].arn
}
