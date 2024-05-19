module "projectspint_ecs_policy" {
  for_each = { 
    for team, config in var.projectsprint_teams : 
    team => config if config.run_ecs 
  }
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.37.1"

  name = "projectspint-ecs-policy-${each.key}"
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
        Resource = "${module.projectsprint_ecs_cluster[0].cluster_arn}*"
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
          "${aws_cloudwatch_log_group.projectsprint_service[each.key].arn}*",
          "${aws_cloudwatch_log_group.projectsprint_db_service[each.key].arn}*", 
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
        ]
        Resource = [
          "${aws_ecs_service.projectsprint_ecs_service[each.key].id}*",
          "${aws_ecs_service.projectsprint_ecs_db_service[each.key].id}*", 
        ]
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "projectsprint_ecs_policy_attachment" {
  for_each = { 
    for team, config in var.projectsprint_teams : 
    team => config if config.run_ecs 
  }

  user      = module.projectsprint_iam_account[each.key].iam_user_name
  policy_arn = module.projectspint_ecs_policy[each.key].arn
}
