resource "aws_elb" "classic-LB" {
  name               = "classic-lb-${var.instance-name}"
  internal           = var.internal-load-balancer
  security_groups    = ["${var.lb-security-group}"]
  subnets            = var.subnets

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 3
    timeout = 3
    target = "TCP:22"
    interval = 30
  }

  listener {
    instance_port = var.instance-port
    instance_protocol = "HTTP"
    lb_port = "80"
    lb_protocol = "HTTP"
  }

  listener {
    instance_port = 22
    instance_protocol = "TCP"
    lb_port = "22"
    lb_protocol = "TCP"
  }

  tags = {
    Name = "classic-lb-${var.instance-name}"
  }
}