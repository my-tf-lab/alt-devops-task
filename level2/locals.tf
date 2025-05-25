locals {
  tags = {
    "terraform_state"     = "level1"
    "terraform_workspace" = var.env_code
    "Owner"               = "alt-devops-team"
  }
}