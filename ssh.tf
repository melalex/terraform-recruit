resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "this" {
  key_name = "${local.project_name}-key-pair"
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_security_group" "ssh" {
  name = "${local.project_name}-ssh"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
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
    Name = "${local.project_name}-ssh"
    Owner = local.owner
  }
}
