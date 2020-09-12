terraform {
  required_version = ">= 0.12"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-${availability_zone}-public-subnet"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-${availability_zone}-private-subnet"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true

  tags = {
    Name = "${var.project_name}-nat-eip"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
