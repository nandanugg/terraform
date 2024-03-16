terraform {
  backend "s3" {
    bucket         = "sprint-tf-state"
    dynamodb_table = "sprint-tf-state"
    key            = "tf-state/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      source  = "hashicorp/aws"
      version = "5.41.0"
    }
  }
}
