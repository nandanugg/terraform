locals {
  project = "sprint"
}

data "aws_key_pair" "nanda" {
  key_name           = "Nanda Personal AWS Key"
  include_public_key = true
}

resource "aws_key_pair" "project_sprint" {
  key_name   = "projectsprint"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDxTTLsIK3GJclbBzi7i/fh7LNQUzVF9paSarwvo69JE+A0r5cnUw/zagW0GHeMzrIdPvURrDMPgy6GFqadJnhgK9QROTUSschNK5WjVwUSzJ9DhVUClUqySjvzqwb7X4kl/OrEK+5PZTSLQmjvvmpbGGLUJFRxjFaZJgTXwx8bZGp/P2DLFGs4lERk6yatN4YncGSjDzmukKMhl6WNiUhBPGT3ouwvbF8K3g5wtizBvdptbVlbPgCHNXigwaH1k5/qb4riUL/m1cORNjcen6EXH7zxoBmGMvfzMJjtSB9UdGgr4jwrsVZm0noUNg95Oc5L+HLqC/Y/zgstfwBwfiy/xH26yW9NuwPnJn+pZF1QXAubhRBADR6biCdTvU3xpTNUQGwFGQSx2MJNA/eVrrSExHQgL89cMtA3Ht9w9GPUR5YLxyg2dZRqUOUjh3j9b7KQDAeTJj6NkKyDPCEhaIo63O1KpD07t9za7RA9i3py9bCKeXN8C4nr7YZpb036gJ3HM0dlyeHz0j45yfjq7s+q3590owqRKZTSl0DDG7d+PYR+e4eQ2H+M1CBa15EcCo58PzgIp0lWrKjtkOCQPTpR/1R+uXT8EOHQatTopW0bN/OqL1HwegZw98q2jjumvgtNGieFPk+d2rAKxY7ltLzYX8VY8cMK1q0yUiDUQXIkgw=="
}

variable subnet_1a {}
variable subnet_1b {}
variable subnet_1c {}

variable start_projectsprint {
  type = bool
  default = false
}

variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "default region"
}

output "ec2_nanda_instance_public_ip" {
  value       = join("", aws_instance.nanda_instance[*].public_ip)
  depends_on  = [aws_instance.nanda_instance]
  sensitive   = true
  description = "nanda_instance public ip"
}

output "ec2_project_sprint_k6_instance_ips" {
  value       = {
    "public_ip": join("", aws_instance.project_sprint_k6_instance[*].public_ip)
  }
  depends_on  = [aws_instance.project_sprint_k6_instance]
  sensitive   = true
  description = "project_sprint_k6_instance IP addresses"
}

output "ec2_project_sprint_instance_2_ips" {
  value = {
    "private_ip" = join("", aws_instance.project_sprint_instance_2[*].private_ip)
    "public_ip"  = join("", aws_instance.project_sprint_instance_2[*].public_ip)
  }
  depends_on  = [aws_instance.project_sprint_instance_2]
  sensitive   = true
  description = "project_sprint_instance_2 IP addresses"
}

output "ec2_project_sprint_instance_ips" {
  value = {
    "private_ip" = join("", aws_instance.project_sprint_instance[*].private_ip)
    "public_ip"  = join("", aws_instance.project_sprint_instance[*].public_ip)
  }
  depends_on  = [aws_instance.project_sprint_instance]
  sensitive   = true
  description = "project_sprint_instance IP addresses"
}

output "ec2_project_sprint_db_address" {
  value       = join("", module.projectsprint-db[*].db_instance_address)
  sensitive   = true
  description = "project_sprint_db_address"
}

output "ec2_project_sprint_db_2_address" {
  value       = join("", module.projectsprint-db-2[*].db_instance_address)
  sensitive   = true
  description = "project_sprint_db_address"
}

output "s3_user_creds" {
  sensitive = true
  value = {
    "id"     = join("", module.s3-user[*].iam_access_key_id)
    "secret" = join("", module.s3-user[*].iam_access_key_secret)
    "status" = join("", module.s3-user[*].iam_access_key_status)
  }
}
