locals {
  major_blocks          = cidrsubnets(var.vpc_cidr_block, 2, 2, 2, 2)
  public_subnet_cidrs   = cidrsubnets(local.major_blocks[0], 6, 6, 6)
  private_subnet_cidrs  = cidrsubnets(local.major_blocks[1], 2, 2, 2)
  db_subnet_cidrs       = cidrsubnets(local.major_blocks[2], 6, 6, 6)
  firewall_subnet_cidrs = cidrsubnets(local.major_blocks[3], 6, 6, 6)

  tags = {
    "terraform_state"     = "level1"
    "terraform_workspace" = var.env_code
    "Owner"               = "alt-devops-team"
  }
}
