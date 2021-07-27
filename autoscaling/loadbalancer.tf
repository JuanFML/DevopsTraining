resource "aws_elb" "classic-lb-http" {
  name               = "classic-lb-http-${var.instance-name}"
  internal           = var.internal-load-balancer
  security_groups    = ["${aws_security_group.Allow-http.id}"]
  subnets            = var.subnets

  listener {
    instance_port     = var.instance-port
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:${var.instance-port}/"
    interval            = 30
  }

  connection_draining   = true

  tags = {
    Name = "classic-lb-http-${var.instance-name}"
  }
}