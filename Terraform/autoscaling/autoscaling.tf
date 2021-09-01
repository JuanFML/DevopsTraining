resource "aws_launch_configuration" "config-autoscale-group" {
  name_prefix   = "config-autoscale-group${var.instance-name}"
  image_id      = var.AMI_id
  instance_type = "t2.micro"
  security_groups = ["${var.security-group}"]
  associate_public_ip_address = var.public-ip
  key_name = "first-key-pair"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "group" {
  name                 = "terraform-autoscale-group${var.instance-name}"
  launch_configuration = aws_launch_configuration.config-autoscale-group.name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = var.subnets
  load_balancers =  ["${aws_elb.classic-LB.name}"]


  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = var.instance-name
    propagate_at_launch = true
  }
}