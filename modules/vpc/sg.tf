resource "aws_security_group" "app" {
  name        = "app"
  description = "Application traffic"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "app_http_https_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.internal_alb.id
  description              = "HTTP/HTTPS from internal ALB traffic"
}

resource "aws_security_group_rule" "app_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "SSH from Bastion traffic"
}

resource "aws_security_group_rule" "app_ingress_ephemeral" {
  type              = "ingress"
  from_port         = 1024
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = [var.main_vpc_cidr]
  description       = "VPC traffic"
}

resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = [var.main_vpc_cidr]
  description       = "Allow all outbound traffic"
}

resource "aws_security_group" "rds" {
  name        = "rds"
  description = "RDS traffic"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "rds_ingress_from_app" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.app.id
  description              = "Allow MySQL traffic from App"
}

resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = [var.main_vpc_cidr]
  description       = "Allow all outbound traffic"
}

resource "aws_security_group" "internal_alb" {
  name        = "internal-alb"
  description = "Internal ALB traffic"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "internal_alb_ingress_from_public_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.internal_alb.id
  source_security_group_id = aws_security_group.public_alb.id
  description              = "Allow traffic from public ALB"
}

resource "aws_security_group_rule" "internal_alb_egress_to_app" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.internal_alb.id
  source_security_group_id = aws_security_group.app.id
  description              = "Allow to App traffic"
}

resource "aws_security_group" "public_alb" {
  name        = "public-alb"
  description = "Public ALB traffic"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "public_alb_ingress_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.public_alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP/HTTPS from internet"
}

resource "aws_security_group_rule" "public_alb_egress_to_internal" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.public_alb.id
  source_security_group_id = aws_security_group.internal_alb.id
  description              = "Allow HTTP/HTTPS to internal ALB"
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Bastion SG"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = [var.home_ip_cidr]
  description       = "SSH from Home"
}

resource "aws_security_group_rule" "bastion_egress_to_app" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = aws_security_group.app.id
  description              = "SSH to App via Bastion"
}
