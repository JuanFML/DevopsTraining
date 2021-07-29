data "aws_ami" "ubuntu" {

  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

module "vpc_2n2" {
  source        = "./vpc"
  main_vpc_cidr = "10.0.0.0/22"
  publicSubnets = ["10.0.0.0/24","10.0.1.0/24"]
  privateSubnets = [ "10.0.2.0/24", "10.0.3.0/24"]
  az = ["us-east-2a", "us-east-2b"]
}

module "auto-scaling-public" {
  source           = "./autoscaling"
  AMI_id           = data.aws_ami.ubuntu.id
  user_data64_file = "install_front.sh"
  subnets          = module.vpc_2n2.publicSubnets_ids
  main_vpc_id      = module.vpc_2n2.main_vpc_id
  internal-load-balancer = false
  instance-name    = "frontend"
  instance-port    = 3000
  public-ip = true
  security-group = module.security-group-frontend.security-group-id
  lb-security-group = module.security-group-frontend.lb-security-group-id
}

module "auto-scaling-private" {
  source         = "./autoscaling"
  AMI_id         = data.aws_ami.ubuntu.id
  user_data64_file = "install_back.sh"
  subnets = module.vpc_2n2.privateSubnets_ids
  main_vpc_id = module.vpc_2n2.main_vpc_id
  internal-load-balancer = true
  instance-name    = "backend"
  instance-port    = 8080
  public-ip = false
  security-group = module.security-group-backend.security-group-id
  lb-security-group = module.security-group-backend.lb-security-group-id
}

module "security-group-frontend" {
  source         = "./securitygroup"
  main_vpc_id = module.vpc_2n2.main_vpc_id
  instance-name    = "frontend"
  instance-port    = 3000
  ingress-configs = {
    "http" = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups =[]
    description = "http access"
  }, "ssh" = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups =[]
    description = "SSH access"
  }, "port" = {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups =[]
    description = "React app port access"
  }
  }
}

module "security-group-backend" {
  depends_on = [
    module.security-group-frontend
  ]
  source         = "./securitygroup"
  main_vpc_id = module.vpc_2n2.main_vpc_id
  instance-name    = "backend"
  instance-port    = 8080
  ingress-configs = {
 "port" = {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = []
    security_groups =["${module.security-group-frontend.security-group-id}"]
    description = "NestJS app port access"
  }}
}