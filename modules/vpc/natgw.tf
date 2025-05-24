resource "aws_eip" "nat" {
  count  = var.nat_gw_enabled ? 1 : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  count = var.nat_gw_enabled ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge({
    "Name" = "natgw-${var.vpc_name}",
    }, var.tags
  )

  depends_on = [aws_internet_gateway.main]
}
