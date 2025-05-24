resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    "Name" = "public-nacl-${var.vpc_name}",
  }, var.tags)
}

resource "aws_network_acl_rule" "public_in_http_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  protocol       = "6"  # TCP
  rule_action   = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port     = 80
  to_port       = 80
}

resource "aws_network_acl_rule" "public_in_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  protocol       = "6"  # TCP
  rule_action   = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port     = 443
  to_port       = 443
}

resource "aws_network_acl_rule" "public_out_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  protocol       = "6"
  rule_action   = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
  from_port     = 1024
  to_port       = 65535
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    "Name" = "private-nacl-${var.vpc_name}",
  }, var.tags)
}

resource "aws_network_acl_rule" "private_in_mysql" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  protocol       = "6"
  rule_action   = "allow"
  egress         = false
  cidr_block     = var.main_vpc_cidr
  from_port     = 3306
  to_port       = 3306
}

resource "aws_network_acl_rule" "private_in_ssh" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  protocol       = "6"
  rule_action   = "allow"
  egress         = false
  cidr_block     = aws_subnet.public["${var.bastion_az}"].cidr_block
  from_port     = 22
  to_port       = 22
}

resource "aws_network_acl_rule" "private_out_ephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 120
  protocol       = "6"
  rule_action   = "allow"
  egress         = true
  cidr_block     = var.main_vpc_cidr
  from_port     = 1024
  to_port       = 65535
}

resource "aws_network_acl_rule" "dns_in_udp" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 130
  protocol       = "17"
  rule_action   = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port     = 53
  to_port       = 53
}

resource "aws_network_acl_rule" "dns_in_tcp" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 140
  protocol       = "6"
  rule_action   = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port     = 53
  to_port       = 53
}

resource "aws_network_acl_rule" "dns_in_udp_private" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 130
  protocol       = "17"
  rule_action   = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port     = 53
  to_port       = 53
}

resource "aws_network_acl_rule" "dns_in_tcp_private" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 140
  protocol       = "6"
  rule_action   = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port     = 53
  to_port       = 53
}

resource "aws_network_acl_rule" "private_in_http" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 150
  protocol       = "6"  # TCP
  rule_action    = "allow"
  egress         = false
  cidr_block     = var.main_vpc_cidr
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_in_https" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 160
  protocol       = "6"  # TCP
  rule_action    = "allow"
  egress         = false
  cidr_block     = var.main_vpc_cidr
  from_port      = 443
  to_port        = 443
}


resource "aws_network_acl_association" "public" {
  for_each = var.nacl_enabled ? aws_subnet.public : {}

  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.public.id
}

resource "aws_network_acl_association" "private" {
  for_each = var.nacl_enabled ? aws_subnet.private : {}

  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.private.id
}