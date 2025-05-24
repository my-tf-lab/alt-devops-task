resource "aws_networkfirewall_rule_group" "allow_https_secureweb" {
  count = var.firewall_enabled ? 1 : 0

  name     = "${var.vpc_name}-allow-https-secureweb"
  capacity = 100
  type     = "STATEFUL"

rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI", "HTTP_HOST"]
        targets              = var.allowed_domains
      }
    }
  }

  tags = merge({
    "Name" = "${var.vpc_name}-allow-https-secureweb",
  }, var.tags)
}

resource "aws_networkfirewall_firewall_policy" "main" {
  count = var.firewall_enabled ? 1 : 0

  name = "${var.vpc_name}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.allow_https_secureweb[0].arn
      priority     = 1
    }
  }

  tags = merge({
    "Name" = "${var.vpc_name}-policy",
  }, var.tags)
}

resource "aws_networkfirewall_firewall" "main" {
  count = var.firewall_enabled ? 1 : 0

  name                = "${var.vpc_name}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main[0].arn
  vpc_id              = aws_vpc.main.id

  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall
    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  delete_protection                 = false
  firewall_policy_change_protection = false
  subnet_change_protection          = false

  tags = merge({
    "Name" = "${var.vpc_name}-firewall"
  }, var.tags)
}