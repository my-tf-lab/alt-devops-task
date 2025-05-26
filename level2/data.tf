data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["alti-${var.env}"]
  }
}

data "aws_subnets" "db" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["db-alti-${var.env}-*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["private-alti-${var.env}-*"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Name"
    values = ["public-alti-${var.env}-*"]
  }
}

data "aws_security_group" "rds" {
  filter {
    name   = "group-name"
    values = ["rds"]
  }

  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "app" {
  filter {
    name   = "group-name"
    values = ["app"]
  }

  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "bastion" {
  filter {
    name   = "group-name"
    values = ["bastion"]
  }

  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "internal_alb" {
  filter {
    name   = "group-name"
    values = ["internal-alb"]
  }

  vpc_id = data.aws_vpc.main.id
}

data "aws_security_group" "public_alb" {
  filter {
    name   = "group-name"
    values = ["public-alb"]
  }

  vpc_id = data.aws_vpc.main.id
}

data "hcp_vault_secrets_app" "demo" {
  app_name = "tf-stack-demo"
}
