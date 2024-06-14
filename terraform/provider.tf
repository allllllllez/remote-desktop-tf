terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  required_version = ">= 1.8"
}

provider "aws" {
  # region = "ap-northeast-1"
  region  = "us-west-2"
  profile = "default" # cf. https://dev.classmethod.jp/articles/terraform-mfa-assumerole-export-credentials/
}
