resource "aws_budgets_budget" "spend_limit" {
  name         = "spend_limit"
  budget_type  = "COST"
  limit_amount = "30"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
}

resource "aws_budgets_budget_action" "spend_limit" {
  count              = var.create_server ? 1 : 0
  budget_name        = aws_budgets_budget.spend_limit.name
  action_type        = "RUN_SSM_DOCUMENTS"
  approval_model     = "AUTOMATIC"
  notification_type  = "ACTUAL"
  execution_role_arn = aws_iam_role.budget_stop_ec2_role.arn
  action_threshold {
    action_threshold_type  = "ABSOLUTE_VALUE"
    action_threshold_value = 10
  }

  definition {
    ssm_action_definition {
      action_sub_type = "STOP_EC2_INSTANCES"
      instance_ids = [
        aws_instance.nanda_instance[0].id
      ]
      region = var.region
    }
  }

  subscriber {
    address           = "nandanugg@gmail.com"
    subscription_type = "EMAIL"
  }
}

# Create the IAM Role
resource "aws_iam_role" "budget_stop_ec2_role" {
  name = "budget_stop_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = ["budgets.amazonaws.com", "ec2.amazonaws.com"]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "allow_assume_budget_stop_ec2_role" {
  name        = "AllowAssumeBudgetStopEC2Role"
  description = "Allow assuming the budget_stop_ec2_role for stopping EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.budget_stop_ec2_role.arn
      },
    ]
  })
}


# Attach the Policies to the Role
resource "aws_iam_role_policy_attachment" "attach_ec2_stop_instances_policy" {
  role       = aws_iam_role.budget_stop_ec2_role.name
  policy_arn = aws_iam_policy.ec2_stop_instances_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_send_budget_notification_policy" {
  role       = aws_iam_role.budget_stop_ec2_role.name
  policy_arn = aws_iam_policy.send_budget_notification_policy.arn

}
resource "aws_iam_role_policy_attachment" "attach_ssm_start_automation_execution_ec2_policy" {
  role       = aws_iam_role.budget_stop_ec2_role.name
  policy_arn = aws_iam_policy.ssm_start_automation_execution.arn
}

resource "aws_iam_policy" "ssm_start_automation_execution" {
  name        = "SSMStartAutomationExecutionPolicy"
  description = "Allows starting SSM automation executions for stopping EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ssm:StartAutomationExecution",
        Resource = "arn:aws:ssm:ap-southeast-1::automation-definition/AWS-StopEC2Instance:*"
      }
    ]
  })
}


resource "aws_iam_policy" "ec2_stop_instances_policy" {
  name = "ec2_stop_instances_policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ec2:StopInstances"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_policy" "send_budget_notification_policy" {
  name = "send_budget_notification_policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = "*"
      },
    ]
  })
}
