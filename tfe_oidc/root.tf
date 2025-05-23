terraform {
    backend "s3" {
    region   = "us-east-1"
    bucket   = "azarov-sso-tf-state-2"
    key      = "oidc2/terraform.tfstate"
    profile = "azarov"

  }

  required_version = ">= 1.12.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
