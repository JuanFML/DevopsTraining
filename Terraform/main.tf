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

# FRONTEND
module "auto-scaling-frontend" {
  source           = "./autoscaling"
  AMI_id           = data.aws_ami.ubuntu.id
  user_data64_file = ""
  subnets          = module.vpc_2n2.publicSubnets_ids
  main_vpc_id      = module.vpc_2n2.main_vpc_id
  internal-load-balancer = false
  instance-name    = "frontend"
  instance-port    = 3000
  public-ip = true
  security-group = aws_security_group.SG-AS-Frontend.id
  lb-security-group = aws_security_group.SG-LB-Frontend.id
}

resource "aws_security_group" "SG-AS-Frontend" {
  name = "Fronted-AS"
  vpc_id = module.vpc_2n2.main_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }
  ingress  {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "React app port access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG-LB-Frontend" {
  name = "Fronted-LB"
  vpc_id = module.vpc_2n2.main_vpc_id


  ingress{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "App access through http"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH host access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# BACKEND
module "auto-scaling-backend" {
  source         = "./autoscaling"
  AMI_id         = data.aws_ami.ubuntu.id
  user_data64_file = ""
  subnets = module.vpc_2n2.privateSubnets_ids
  main_vpc_id = module.vpc_2n2.main_vpc_id
  internal-load-balancer = true
  instance-name    = "backend"
  instance-port    = 8080
  public-ip = false
  security-group = aws_security_group.SG-AS-Backend.id
  lb-security-group = aws_security_group.SG-LB-Backend.id
}

resource "aws_security_group" "SG-AS-Backend" {
  depends_on = [aws_security_group.SG-LB-Backend]
  name ="Backend-AS"
  vpc_id = module.vpc_2n2.main_vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups =["${aws_security_group.SG-LB-Backend.id}"]
    description = "NestJS app port access"
  }

  ingress  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups =["${aws_security_group.SG-LB-Backend.id}"]
    description = "SSH port access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG-LB-Backend" {
  depends_on = [aws_security_group.SG-AS-Bastion, aws_security_group.SG-AS-Frontend]
  name ="Backend-LB"
  vpc_id = module.vpc_2n2.main_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups =["${aws_security_group.SG-AS-Frontend.id}"]
    description = "App access through http"
  }

  ingress  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups =["${aws_security_group.SG-AS-Bastion.id}"]
    description = "Bastion host access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# BASTION
module "Bastion-auto-scaling" {
  source           = "./autoscaling"
  AMI_id           = data.aws_ami.ubuntu.id
  user_data64_file = ""
  subnets          = module.vpc_2n2.publicSubnets_ids
  main_vpc_id      = module.vpc_2n2.main_vpc_id
  internal-load-balancer = false
  instance-name    = "Bastion-host"
  instance-port    = 80
  public-ip = true
  security-group = aws_security_group.SG-AS-Bastion.id
  lb-security-group = aws_security_group.SG-LB-Bastion.id
}

resource "aws_security_group" "SG-AS-Bastion" {
  name = "Bastion-AS"
  vpc_id = module.vpc_2n2.main_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Bastion SSH autoscaling access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "SG-LB-Bastion" {
  name ="Bastion-LB"
  vpc_id = module.vpc_2n2.main_vpc_id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Bastion SSH LB access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}