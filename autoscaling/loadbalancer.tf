resource "aws_lb" "loadbalencer" {
  name               = "autoscale-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.loadbalancer.id}"]
  subnets            = var.publicSubnets


  tags = {
    Environment = "production"
  }
}