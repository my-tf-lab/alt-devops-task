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

data "aws_security_group" "rds" {
  filter {
    name   = "group-name"
    values = ["rds"]
  }

  vpc_id = data.aws_vpc.main.id
}

data "hcp_vault_secrets_app" "web_application" {
  app_name = "tf-stack-demo"
}

resource "aws_db_subnet_group" "main" {
  name       = "alti-${var.env}-subnet-group"
  subnet_ids = data.aws_subnets.db.ids

  tags = merge({
    "Name" = "alti-${var.env}-subnet-group",
    }, local.tags
  )
}

resource "aws_db_instance" "mysql" {
  identifier              = "mysql-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = data.hcp_vault_secrets_app.web_application.secrets["rds_username"]
  password                = data.hcp_vault_secrets_app.web_application.secrets["rds_password"]
  db_name                 = "alti-db"
  port                    = 3306
  publicly_accessible     = false
  multi_az                = false
  storage_encrypted       = true
  skip_final_snapshot     = true

  vpc_security_group_ids  = [data.aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name

  tags = merge({
    "Name" = "alti-${var.env}-db",
    }, local.tags
  )
}
