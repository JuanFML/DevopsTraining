resource "aws_security_group" "Allow-http" {
  name = "${var.security-group-lb-name}"
  vpc_id      = var.main_vpc_id

  # ingress {
  #   from_port   = var.instance-port
  #   to_port     = var.instance-port
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  dynamic "ingress" {
    for_each = var.ingress-lb-configs
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
      security_groups =ingress.value.security_groups
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}