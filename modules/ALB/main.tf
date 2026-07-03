resource "aws_lb" "ext-alb" {
  name               = "ext-alb"
  internal           = false
  security_groups    = [var.ext_alb_sg_id]
  subnets            = [var.public_subnets[0], var.public_subnets[1]]
  ip_address_type    = "ipv4"
  load_balancer_type = "application"

  tags = merge(var.tags, { Name = "ext-alb" })
}

resource "aws_lb_target_group" "nginx-tgt" {
  name        = "nginx-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "nginx-listener" {
  load_balancer_arn = aws_lb.ext-alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tgt.arn
  }
}

resource "aws_lb" "ialb" {
  name               = "int-alb"
  internal           = true
  security_groups    = [var.int_alb_sg_id]
  subnets            = [var.private_subnets[0], var.private_subnets[1]]
  ip_address_type    = "ipv4"
  load_balancer_type = "application"

  tags = merge(var.tags, { Name = "int-alb" })
}

resource "aws_lb_target_group" "wordpress-tgt" {
  name        = "wordpress-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "tooling-tgt" {
  name        = "tooling-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.ialb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress-tgt.arn
  }
}

resource "aws_lb_listener_rule" "tooling-listener" {
  listener_arn = aws_lb_listener.web-listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tooling-tgt.arn
  }

  condition {
    host_header {
      values = ["tooling.oddshare.com"]
    }
  }
}
