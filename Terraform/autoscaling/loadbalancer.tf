# resource "aws_lb" "Application-LB" {
#   name               = "Application-lb-${var.instance-name}"
#   internal           = var.internal-load-balancer
#   load_balancer_type = "application"
#   security_groups    = ["${var.lb-security-group}"]
#   subnets            = var.subnets
#   tags = {
#     Name = "Application-lb-${var.instance-name}"
#   }
# }

# resource "aws_lb" "Network-LB" {
#   name               = "Network-lb-${var.instance-name}"
#   internal           = var.internal-load-balancer
#   load_balancer_type = "network"
#   subnets            = var.subnets

#   tags = {
#     Name = "Network-lb-${var.instance-name}"
#   }
# }

# resource "aws_lb_listener" "http-listener" {
#   load_balancer_arn = aws_lb.Application-LB.arn
#   port              = "80"
#   protocol          = "HTTP"
#  default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.lb-target-group-app.arn
#   }
# }

# resource "aws_lb_listener" "ssh-listener" {
#   load_balancer_arn = aws_lb.Network-LB.arn
#   port              = "22"
#   protocol          = "TCP"
#  default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.lb-target-group-network.arn
#   }
# }

# resource "aws_lb_target_group" "lb-target-group-app" {
#   name     = "Target-${var.instance-name}-app"
#   port     = var.instance-port
#   protocol = "HTTP"
#   vpc_id   = var.main_vpc_id
#   target_type = "instance"
#     health_check {
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     timeout             = 3
#     path              = "/"
#     interval            = 30
#     port = var.instance-port
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_lb_target_group" "lb-target-group-network" {
#   name     = "Target-${var.instance-name}-network"
#   port     = "22"
#   protocol = "TCP"
#   vpc_id   = var.main_vpc_id
#   target_type = "instance"
#   lifecycle {
#     create_before_destroy = true
#   }
# }








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