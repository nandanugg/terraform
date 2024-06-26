output "root_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "ec2_nanda_instance_public_ip" {
  value       = join("", aws_instance.nanda_instance[*].public_ip)
  depends_on  = [aws_instance.nanda_instance]
  sensitive   = true
  description = "nanda_instance public ip"
}

output "ec2_project_sprint_k6_instance_ips" {
  value = {
    "private_ip" = join("", aws_instance.project_sprint_instance[*].private_ip)
    "public_ip"  = join("", aws_instance.projectsprint_k6[*].public_ip)
  }
  depends_on  = [aws_instance.projectsprint_k6]
  sensitive   = true
  description = "projectsprint_k6 IP addresses"
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

output "projectsprint_user_credentials" {
  value = {
    for acc, team in var.projectsprint_teams :
    acc => {
      username   = module.projectsprint_iam_account[acc].iam_user_name
      password   = module.projectsprint_iam_account[acc].iam_user_login_profile_password
      access_key = module.projectsprint_iam_account[acc].iam_access_key_id
      secret_key = module.projectsprint_iam_account[acc].iam_access_key_secret
    }
  }
  sensitive = true
}
