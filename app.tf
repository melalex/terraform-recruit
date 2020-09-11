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

resource "aws_security_group" "app" {
  name = "${local.project_name}-app"
  description = "Allow incoming HTTP connections."
  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 8080
    to_port = 8080
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
    from_port = aws_db_instance.this.port
    to_port = aws_db_instance.this.port
    protocol = "tcp"
    cidr_blocks = [
      aws_subnet.private.cidr_block
    ]
  }

  tags = {
    Name = "${local.project_name}-app"
    Owner = local.owner
  }
}

resource "aws_instance" "app" {
  ami = data.aws_ami.app.id
  availability_zone = local.availability_zone
  instance_type = "m1.small"
  key_name = aws_key_pair.this.key_name

  vpc_security_group_ids = [
    aws_security_group.app.id,
    aws_security_group.ssh.id
  ]

  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "${local.project_name}-app"
    Owner = local.owner
  }
}

resource "aws_eip" "app" {
  instance = aws_instance.app.id
  vpc = true
}

resource "aws_elb" "app" {
  name = "${local.project_name}-elb"
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  availability_zones = [
    local.availability_zone
  ]

  instances = [
    aws_instance.app.id
  ]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8080/health"
    interval = 30
  }

  tags = {
    Name = "${local.project_name}-elb"
  }
}
