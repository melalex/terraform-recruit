terraform {
  required_version = ">= 0.12"
}

locals {
  alb_port = 80
  alb_protocol = "HTTP"
}

data "aws_ami" "app" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    ]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"
    ]
  }

  owners = [
    "099720109477"
  ]
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "this" {
  key_name = "${var.project_name}-key-pair"
  public_key = tls_private_key.this.public_key_openssh

  tags = {
    Name = "${var.project_name}-key-pair"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_security_group" "app" {
  name = "${var.project_name}-app-sg"

  description = "Allow incoming HTTP connections."
  vpc_id = var.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  ingress {
    from_port = var.app_port
    to_port = var.app_port
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_security_group" "alb" {
  name = "${var.project_name}-alb-sg"

  description = "Allow incoming HTTP connections."
  vpc_id = var.vpc_id

  ingress {
    from_port = local.alb_port
    to_port = local.alb_port
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_instance" "this" {
  ami = data.aws_ami.app.id
  instance_type = "t3.micro"
  key_name = aws_key_pair.this.key_name

  vpc_security_group_ids = [
    aws_security_group.app.id
  ]

  subnet_id = var.subnet_ids[0]
  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "${var.project_name}-app"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  vpc = true

  tags = {
    Name = "${var.project_name}-app-eip"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_alb" "this" {
  name = "${var.project_name}-app-lb"

  subnets = var.subnet_ids

  security_groups = [
    aws_security_group.alb.id
  ]

  tags = {
    Name = "${var.project_name}-alb"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port = local.alb_port
  protocol = local.alb_protocol

  default_action {
    target_group_arn = aws_alb_target_group.this.arn
    type = "forward"
  }
}

resource "aws_alb_target_group" "this" {
  name = "${var.project_name}-tg"
  port = var.app_port
  protocol = var.app_protocol
  vpc_id = var.vpc_id

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path = "/health"
    port = var.app_port
  }
}

resource "aws_alb_target_group_attachment" "this" {
  target_group_arn = aws_alb_target_group.this.arn
  target_id = aws_instance.this.id
  port = var.app_port
}