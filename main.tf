module "vpc_example" {
  source = "./vpc"
  main_vpc_cidr = "10.0.0.0/22"
  public_subnets = "10.0.0.0/24"
  public_subnets2 = "10.0.1.0/24"
  private_subnets = "10.0.2.0/24"
  private_subnets2 = "10.0.3.0/24"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "testing" {
  name_prefix   = "testing"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data_base64 = "${filebase64("install_apache.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.testing.name
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  vpc_zone_identifier = [module.vpc_example.subnetpublics]

  lifecycle {
    create_before_destroy = true
  }
}