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
      source  = "hashicorp/aws"
      version = "5.35.0"
    }
  }
}
