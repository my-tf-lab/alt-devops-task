resource "aws_lb" "internal" {
  name                       = "${local.node_name}-internal"
  internal                   = true
  load_balancer_type         = "application"
  subnets                    = data.aws_subnets.private.ids
  security_groups            = [data.aws_security_group.internal_alb.id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "to_app" {
  name        = "tg-to-app"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.to_app.arn
  }
}

resource "aws_autoscaling_attachment" "asg_to_target_group" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn    = aws_lb_target_group.to_app.arn
}

resource "aws_lb" "public" {
  name                       = "${local.node_name}-public"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = data.aws_subnets.public.ids
  security_groups            = [data.aws_security_group.public_alb.id]
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "to_internal_alb" {
  name        = "tg-to-int-alb"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.to_internal_alb.arn
  }
}
