terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "roboshop5"
    key            = "cloud_resume/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "roboshop_tf_state_locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
