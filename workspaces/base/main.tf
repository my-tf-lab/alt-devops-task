resource "tfe_variable" "tf_cli_args" {
  key          = "TF_CLI_ARGS_plan"
  value        = "-var-file=env/${var.environment_code}.tfvars"
  category     = "env"
  workspace_id = tfe_workspace.this.id
}

resource "tfe_variable" "tfe_prov" {
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.this.id
  sensitive    = false
}

resource "tfe_variable" "tfe_role" {
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = var.tfe_aws_role
  category     = "env"
  workspace_id = tfe_workspace.this.id
  sensitive    = true
}

resource "tfe_variable" "hcp_client_id" {
  key          = "HCP_CLIENT_ID"
  value        = var.hcp_client_id
  category     = "env"
  workspace_id = tfe_workspace.this.id
}

resource "tfe_variable" "hcp_client_secret" {
  key          = "HCP_CLIENT_SECRET"
  value        = var.hcp_client_secret
  category     = "env"
  workspace_id = tfe_workspace.this.id
  sensitive    = true
}

resource "tfe_workspace" "this" {
  name                = "${var.working_directory}-${var.environment_code}"
  organization        = "tetheus-corp"
  working_directory   = var.working_directory
  global_remote_state = true
  terraform_version   = "1.12.1"
  tag_names           = var.environment_code == "default" ? ["global"] : [split("-", var.environment_code)[0], split("-", var.environment_code)[1], lower(var.working_directory)]

  vcs_repo {
    identifier     = "my-tf-lab/alt-devops-task"
    branch         = var.branch
    oauth_token_id = var.oauth_token_id
  }
}
