terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "tetheus-corp"
  }

  required_version = ">= 1.12.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "0.106.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.tags
  }
}

provider "hcp" {
}
