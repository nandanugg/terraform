locals {
  project = "sprint"
}

data "aws_key_pair" "nanda" {
  key_name           = "Nanda Personal AWS Key"
  include_public_key = true
}

resource "aws_key_pair" "project_sprint" {
  key_name   = "projectsprint"
  public_key = var.projectsprint_vm_public_key
}


variable subnet_1a {}
variable subnet_1b {}
variable subnet_1c {}

variable projectsprint_vm_public_key {
  type = string
}

variable projectsprint_start {
  type = bool
  default = false
}

variable projectsprint_db_password {
  type = string
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
