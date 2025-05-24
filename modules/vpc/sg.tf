resource "aws_security_group" "app" {
  name        = "app"
  description = "Application traffic"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

# Ingress: HTTP/HTTPS from internal ALB
resource "aws_security_group_rule" "app_http_https_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.internal_alb.id
  description              = "HTTP/HTTPS from internal ALB traffic"
}

# Ingress: SSH from Bastion
resource "aws_security_group_rule" "app_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = aws_security_group.bastion.id
  description              = "SSH from Bastion traffic"
}

# Ingress: Ephemeral from VPC
resource "aws_security_group_rule" "app_ingress_ephemeral" {
  type              = "ingress"
  from_port         = 1024
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = [var.main_vpc_cidr]
  description       = "Ephemeral from VPC traffic"
}

# Egress: All to VPC
resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.app.id
  cidr_blocks       = [var.main_vpc_cidr]
  description       = "Allow all outbound traffic"
}

# 2. RDS Security Group
resource "aws_security_group" "rds" {
  name        = "rds"
  description = "RDS SG"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

# Ingress: MySQL from App
resource "aws_security_group_rule" "rds_ingress_from_app" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.app.id
  description              = "MySQL from App"
}

# Egress: All in VPC
resource "aws_security_group_rule" "rds_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = [var.main_vpc_cidr]
  description       = "Allow all outbound traffic"
}

# 3. Internal ALB SG
resource "aws_security_group" "internal_alb" {
  name        = "internal-alb"
  description = "Internal ALB SG"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

# Ingress: 80/443 from Public ALB
resource "aws_security_group_rule" "internal_alb_ingress_from_public_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.internal_alb.id
  source_security_group_id = aws_security_group.public_alb.id
  description              = "Allow traffic from public ALB"
}

# Egress: To App SG
resource "aws_security_group_rule" "internal_alb_egress_to_app" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.internal_alb.id
  source_security_group_id = aws_security_group.app.id
  description              = "Allow to App traffic"
}

# 4. Public ALB SG
resource "aws_security_group" "public_alb" {
  name        = "public-alb"
  description = "Public ALB SG"
  vpc_id      = aws_vpc.main.id
  tags        = var.tags
}

# Ingress: 80/443 from Internet
resource "aws_security_group_rule" "public_alb_ingress_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.public_alb.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP/HTTPS from internet"
}

# Egress: To internal ALB
resource "aws_security_group_rule" "public_alb_egress_to_internal" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.public_alb.id
  source_security_group_id = aws_security_group.internal_alb.id
  description              = "LLOW HTTP/HTTPS to internal ALB"
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
  cidr_blocks       = [var.my_home_ip]
  description       = "SSH from Home"
}

resource "aws_security_group_rule" "bastion_egress_to_app" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion.id
  source_security_group_id = aws_security_group.app.id
  description              = "SSH to App FROM Bastion"
}
