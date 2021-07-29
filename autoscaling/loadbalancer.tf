# resource "aws_elb" "classic-lb-http" {
#   name               = "classic-lb-http-${var.instance-name}"
#   internal           = var.internal-load-balancer
#   security_groups    = ["${aws_security_group.Allow-http.id}"]
#   subnets            = var.subnets

#   listener {
#     instance_port     = var.instance-port
#     instance_protocol = "http"
#     lb_port           = 80
#     lb_protocol       = "http"
#   }
#   health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     target              = "HTTP:${var.instance-port}/"
#     interval            = 30
#   }

#   connection_draining   = true

#   tags = {
#     Name = "classic-lb-http-${var.instance-name}"
#   }
# }

resource "aws_lb" "loadbalancer-autoscalegroup" {
  name               = "loadbalancer-${var.instance-name}"
  internal           = var.internal-load-balancer
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.Allow-http.id}"]
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
    # redirect {
    #   port        = "${var.instance-port}"
    #   protocol    = "HTTP"
    #   status_code = "HTTP_301"
    # }
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }


}

resource "aws_lb_target_group" "lb-target-group" {
  name     = "lb-target-group-${var.instance-name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.main_vpc_id

    health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path              = "/"
    interval            = 30
    port = "${var.instance-port}"
  }
}
