# ECS Task Execution Role
resource "aws_iam_role" "projectsprint_ecs_task_execution_service_role" {
  name = "projectsprint_ecs_task_execution_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_service_role_policy" {
  role       = aws_iam_role.projectsprint_ecs_task_execution_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "projectsprint_ecs_task_execution_role_policy" {
  name = "projectsprint_ecs_task_execution_role_policy"
  role = aws_iam_role.projectsprint_ecs_task_execution_service_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "appmesh:StreamAggregatedResources",
          "appmesh:DescribeMesh",
          "appmesh:DescribeVirtualNode",
          "appmesh:DescribeVirtualService",
          "appmesh:ListVirtualNodes",
          "appmesh:ListVirtualServices"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "projectsprint_ecs_task_role" {
  name = "projectsprint_ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "projectsprint_ecs_task_appmesh_policy" {
  name = "projectsprint_ecs_task_appmesh_policy"
  role = aws_iam_role.projectsprint_ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "appmesh:StreamAggregatedResources",
          "appmesh:DescribeMesh",
          "appmesh:DescribeVirtualNode",
          "appmesh:DescribeVirtualService",
          "appmesh:ListVirtualNodes",
          "appmesh:ListVirtualServices"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.projectsprint_ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Service Role
resource "aws_iam_role" "projectsprint_ecs_service_role" {
  name = "projectsprint_ecs_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "projectsprint_ecs_service_policy" {
  name        = "projectsprint_ecs_service_policy"
  description = "Policy for ECS service role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterTargets",
          "ec2:Describe*",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms",
          "ecs:CreateCluster",
          "ecs:DeleteCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:RegisterContainerInstance",
          "ecs:RunTask",
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:UpdateService",
          "ecs:Describe*",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecs:DescribeTaskDefinition"
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "projectsprint_ecs_service_role_policy" {
  role       = aws_iam_role.projectsprint_ecs_service_role.name
  policy_arn = aws_iam_policy.projectsprint_ecs_service_policy.arn
}

