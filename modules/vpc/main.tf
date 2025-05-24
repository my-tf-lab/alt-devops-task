data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.main_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({
    "Name" = var.vpc_name,
    }, var.tags
  )
}

resource "aws_subnet" "public" {
  for_each = { for i, cidr in var.public_subnet_cidrs : i => cidr }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone = data.aws_availability_zones.available.names[tonumber(each.key) % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = merge({
    "Name" = "public-${var.vpc_name}-${each.key}",
    }, var.tags
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_subnet" "private" {
  for_each = { for i, cidr in var.private_subnet_cidrs : i => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[tonumber(each.key) % length(data.aws_availability_zones.available.names)]

  tags = merge({
    "Name" = "private-${var.vpc_name}-${each.key}",
    }, var.tags
  )
}

resource "aws_subnet" "db" {
  for_each = { for i, cidr in var.db_subnet_cidrs : i => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[tonumber(each.key) % length(data.aws_availability_zones.available.names)]

  tags = merge({
    "Name" = "db-${var.vpc_name}-${each.key}",
    }, var.tags
  )
}

resource "aws_subnet" "firewall" {
  for_each = { for i, cidr in var.firewall_subnet_cidrs : i => cidr }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = data.aws_availability_zones.available.names[tonumber(each.key) % length(data.aws_availability_zones.available.names)]

  tags = merge({
    "Name" = "firewall-${var.vpc_name}-${each.key}",
    }, var.tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    "Name" = "igw-${var.vpc_name}",
    }, var.tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.nat_gw_enabled && !var.firewall_enabled ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  dynamic "route" {
    for_each = var.firewall_enabled ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      vpc_endpoint_id = lookup(
        aws_networkfirewall_firewall.main.firewall_status[0].sync_states,
        aws_subnet.private[each.key].availability_zone,
        null
      ).attachment[0].endpoint_id
    }
  }

  tags = merge({
    "Name" = "private-rt-${var.vpc_name}-${each.key}",
  }, var.tags)
}

resource "aws_route_table" "firewall" {
  for_each = aws_subnet.firewall

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.main_vpc_cidr
    gateway_id = "local"
  }

  tags = {
    Name = "firewall-rt-${var.vpc_name}-${each.key}"
  }
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id

  # no internet route added intentionally
  tags = {
    Name = "db-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "firewall" {
  for_each = aws_subnet.firewall

  subnet_id      = each.value.id
  route_table_id = aws_route_table.firewall[each.key].id
}
