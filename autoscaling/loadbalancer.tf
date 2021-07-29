resource "aws_lb" "loadbalancer-autoscalegroup" {
  name               = "loadbalancer-${var.instance-name}"
  internal           = var.internal-load-balancer
  load_balancer_type = "application"
  security_groups    = ["${var.lb-security-group}"]
  subnets            = var.subnets
  tags = {
    Name = "classic-lb-http-${var.instance-name}"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.loadbalancer-autoscalegroup.arn
  port              = "80"
  protocol          = "HTTP"
 default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }
}

resource "aws_lb_target_group" "lb-target-group" {
  name     = "lb-target-group-${var.instance-name}"
  port     = "${var.instance-port}"
  protocol = "HTTP"
  vpc_id   = var.main_vpc_id
  target_type = "instance"
    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path              = "/"
    interval            = 30
    port = "${var.instance-port}"
  }
  lifecycle {
    create_before_destroy = true
  }
}
