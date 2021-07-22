resource "aws_launch_configuration" "aws-config" {
  name_prefix   = "config"
  image_id      = var.AMI_id
  instance_type = "t2.micro"
  user_data_base64 = "${filebase64(var.user_data64_file)}"
  security_groups = ["${aws_security_group.autoscale.id}"]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "group" {
  name                 = "terraform-autoscale-group"
  launch_configuration = aws_launch_configuration.aws-config.name
  min_size             = 1
  max_size             = 1
  vpc_zone_identifier  = var.vpc_identifier

  lifecycle {
    create_before_destroy = true
  }

}