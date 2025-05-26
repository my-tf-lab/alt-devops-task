resource "aws_lb" "internal" {
  name               = "${local.node_name}-internal"
  internal           = true
  load_balancer_type = "application"
  subnets            = data.aws_subnets.private.ids
  security_groups    = [data.aws_security_group.internal_alb.id]
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
  name               = "public-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnets.public.ids
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "nlb_tg_to_alb" {
  name        = "nlb-to-alb-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.main.id
  target_type = "alb"
}

resource "aws_lb_target_group_attachment" "attach_alb_to_nlb" {
  target_group_arn = aws_lb_target_group.nlb_tg_to_alb.arn
  target_id        = aws_lb.internal_alb.arn
  port             = 80
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.public_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg_to_alb.arn
  }
}
