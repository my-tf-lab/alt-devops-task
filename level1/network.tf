locals {
  major_blocks          = cidrsubnets(var.vpc_cidr_block, 2, 2, 2, 2)
  public_subnet_cidrs   = cidrsubnets(local.major_blocks[0], 6, 6, 6)
  private_subnet_cidrs  = cidrsubnets(local.major_blocks[1], 2, 2, 2)
  db_subnet_cidrs       = cidrsubnets(local.major_blocks[2], 6, 6, 6)
  firewall_subnet_cidrs = cidrsubnets(local.major_blocks[3], 10, 10, 10)

  tags = {
    "terraform_state"     = "level1"
    "terraform_workspace" = var.env_code
    "Owner"               = "alt-devops-team"
  }
}

module "vpc" {
  source = "../modules/vpc"

  main_vpc_cidr         = var.vpc_cidr_block
  vpc_name              = "alti-${var.env}"
  public_subnet_cidrs   = local.public_subnet_cidrs
  private_subnet_cidrs  = local.private_subnet_cidrs
  db_subnet_cidrs       = local.db_subnet_cidrs
  firewall_subnet_cidrs = local.firewall_subnet_cidrs

  nat_gw_enabled   = false
  firewall_enabled = false
  nacl_enabled     = true
  bastion_az       = 0
  allowed_domains  = var.allowed_domains
  home_ip_cidr     = "80.238.119.82/32"
  tags             = local.tags
}
