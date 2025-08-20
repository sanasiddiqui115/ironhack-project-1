resource "aws_lb" "app" {
  name               = "vote-result-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  tags = {
    Name = "vote-result-alb"
  }
}

resource "aws_lb_target_group" "vote" {
  name        = "tg-vote"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
    path     = "/"
    matcher  = "200-399"
    interval = 15
    timeout  = 5
  }
}

resource "aws_lb_target_group" "result" {
  name        = "tg-result"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
    path     = "/"
    matcher  = "200-399"
    interval = 15
    timeout  = 5
  }
}

resource "aws_lb_target_group_attachment" "vote" {
  target_group_arn = aws_lb_target_group.vote.arn
  target_id        = var.vote_instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "result" {
  target_group_arn = aws_lb_target_group.result.arn
  target_id        = var.result_instance_id
  port             = 80
}

resource "aws_lb_listener" "http_80" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_443" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "vote_host" {
  listener_arn = aws_lb_listener.https_443.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vote.arn
  }

  condition {
    host_header {
      values = ["vote.${var.root_domain}"]
    }
  }
}

resource "aws_lb_listener_rule" "result_host" {
  listener_arn = aws_lb_listener.https_443.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.result.arn
  }

  condition {
    host_header {
      values = ["result.${var.root_domain}"]
    }
  }
}
