resource "aws_lb" "Applicatiom-loadbalancer" {
  name               = "Application-lb-${var.instance-name}"
  internal           = var.internal-load-balancer
  load_balancer_type = "application"
  security_groups    = ["${var.lb-security-group}"]
  subnets            = var.subnets
  tags = {
    Name = "Application-lb-${var.instance-name}"
  }
}
resource "aws_lb" "Network-loadbalancer" {
  name               = "Netowrk-lb-${var.instance-name}"
  internal           = var.internal-load-balancer
  load_balancer_type = "network"
  subnets            = var.subnets
  tags = {
    Name = "Network-lb-${var.instance-name}"
  }
}

resource "aws_lb_listener" "http-listener" {
  load_balancer_arn = aws_lb.Applicatiom-loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"
 default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }
}

resource "aws_lb_listener" "ssh-listener" {
  load_balancer_arn = aws_lb.Network-loadbalancer.arn
  port              = "22"
  protocol          = "TCP"
 default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group-network.arn
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


resource "aws_lb_target_group" "lb-target-group-network" {
  name     = "lb-target-${var.instance-name}-network"
  port     = "${var.instance-port}"
  protocol = "TCP"
  vpc_id   = var.main_vpc_id
  target_type = "instance"
  lifecycle {
    create_before_destroy = true
  }
}