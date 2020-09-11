provider "aws" {
  version = "~> 3.0"
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_availability_zones" "this" {}

locals {
  availability_zone = data.aws_availability_zones.this.names[0]

  project_name = "terraform-recruit"
  owner = "melalex"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = local.project_name
    Owner = local.owner
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.this.id
  cidr_block = "10.0.0.0/24"
  availability_zone = local.availability_zone

  tags = {
    Name = local.project_name
    Owner = local.owner
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = local.project_name
    Owner = local.owner
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"
  availability_zone = local.availability_zone

  tags = {
    Name = local.project_name
    Owner = local.owner
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.private.id
  tags = {
    Name = local.project_name
    Owner = local.owner
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_db_subnet_group" "this" {
  name = "${aws_db_instance.this.identifier}-subnet-group"

  subnet_ids = [
    aws_subnet.private.id
  ]
}

resource "aws_db_instance" "this" {
  name = "${local.project_name}-db"
  allocated_storage = 1
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  username = var.db_user
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.this.id
  parameter_group_name = "default.mysql5.7"
}

resource "null_resource" "db_setup" {
  depends_on = [
    "aws_db_instance.this"
  ]

  provisioner "file" {
    source      = "/config/init_db.sh"
    destination = "/tmp/config/init_db.sh"
  }

  provisioner "file" {
    source      = "/config/init_db.sql"
    destination = "/tmp/config/init_db.sql"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/config/init_db.sh",
      "/tmp/script.sh args",
    ]
  }

  provisioner "remote-exec" {
    command = "mysql --host=${aws_db_instance.this.address} --port=${aws_db_instance.this.port} --user=${var.db_user} < config/init_db.sql"
    environment = {
      MYSQL_PWD = var.db_password
    }
  }
}
