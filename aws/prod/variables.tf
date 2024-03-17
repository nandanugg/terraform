locals {
  project = "sprint"
}

data "aws_key_pair" "nanda" {
  key_name           = "Nanda Personal AWS Key"
  include_public_key = true
}

data "aws_key_pair" "project_sprint" {
  key_name           = "Project Sprint Key"
  include_public_key = true
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

output "ec2_project_sprint_k6_instance_public_ip" {
  value       = join("", aws_instance.project_sprint_k6_instance[*].public_ip)
  depends_on  = [aws_instance.project_sprint_k6_instance]
  sensitive   = true
  description = "project_sprint_k6_instance public ip"
}


output "ec2_project_sprint_instance_private_ip" {
  value       = join("", aws_instance.project_sprint_instance[*].private_ip)
  depends_on  = [aws_instance.project_sprint_instance]
  sensitive   = true
  description = "project_sprint_instance private ip"
}
output "ec2_project_sprint_instance_public_ip" {
  value       = join("", aws_instance.project_sprint_instance[*].public_ip)
  depends_on  = [aws_instance.project_sprint_instance]
  sensitive   = true
  description = "project_sprint_instance public ip"
}

output "ec2_project_sprint_db_instance_username" {
  value       = length(module.projectsprint-db) > 0 ? one(module.projectsprint-db).db_instance_usernamed : null
  sensitive   = true
  description = "project_sprint_db_instance_username"
}
output "ec2_project_sprint_db_instance_ca_cert_identifier" {
  value       = length(module.projectsprint-db) > 0 ? one(module.projectsprint-db).db_instance_ca_cert_identifier : null
  sensitive   = true
  description = "project_sprint_db_instance_ca_cert_identifier"
}
output "ec2_project_sprint_db_address" {
  value       = length(module.projectsprint-db) > 0 ? one(module.projectsprint-db).db_instance_address : null
  sensitive   = true
  description = "project_sprint_db_address"
}

output "s3_user_creds" {
  sensitive = true
  value = {
    "id"     = module.s3-user.iam_access_key_id
    "secret" = module.s3-user.iam_access_key_secret
    "status" = module.s3-user.iam_access_key_status
  }
}
