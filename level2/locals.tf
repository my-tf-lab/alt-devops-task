locals {
  node_name    = "alti-${var.env}"
  bastion_name = "${local.node_name}-bastion"
  tags = {
    "terraform_state"     = "level2"
    "terraform_workspace" = var.env_code
    "Owner"               = "alt-devops-team"
  }
}
