terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket  = "azarov-sso-tf-state-2"
    key     = "workspaces-alt/terraform.tfstate"
    profile = "azarov"
  }

  required_version = ">= 1.12.1"

  required_providers {
    tfe = {
      version = "0.65.2"
    }
  }
}

provider "tfe" {
  token    = var.tfe_token
  hostname = "app.terraform.io"
}

module "terraform_workspace" {
  source = "./base"

  for_each = local.workspaces

  working_directory = split("-", each.key)[0]
  environment_code  = trimprefix(each.key, "${split("-", each.key)[0]}-")
  tfe_token         = var.tfe_token
  branch            = each.value
  oauth_token_id    = var.oauth_token_id
  hcp_client_id     = var.hcp_client_id
  hcp_client_secret = var.hcp_client_secret
  tfe_aws_role      = var.tfe_aws_role
}
