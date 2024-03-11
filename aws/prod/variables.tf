locals {
  project = "sprint"
}

data "aws_key_pair" "nanda" {
  key_name           = "Nanda Personal AWS Key"
  include_public_key = true
}


variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "default region"
}

variable "create_server" {
  type    = bool
  default = false

}

output "ec2_nanda_big_instance_public_ip" {
  value       = join("", aws_instance.nanda_big_instance[*].public_ip)
  depends_on  = [aws_instance.nanda_big_instance]
  sensitive   = true
  description = "nanda_instance public ip"
}

output "s3_user_creds" {
  sensitive = true
  value = {
    "id"     = module.s3-user.iam_access_key_id
    "secret" = module.s3-user.iam_access_key_secret
    "status" = module.s3-user.iam_access_key_status
  }
}
