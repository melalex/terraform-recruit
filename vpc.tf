locals {
  private_az_count = 2
  public_az = data.aws_availability_zones.this.names[0]

  subnets = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

data "aws_availability_zones" "this" {}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_name}-vpc"
    Owner = local.owner
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.this.id
  cidr_block = local.subnets[0]
  availability_zone = local.public_az

  tags = {
    Name = "${local.project_name}-public-subnet"
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
    Name = "${local.project_name}-public-rt"
    Owner = local.owner
  }
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  count = local.private_az_count

  vpc_id = aws_vpc.this.id
  cidr_block = local.subnets[count.index + 1]
  availability_zone = data.aws_availability_zones.this.names[count.index]

  tags = {
    Name = "${local.project_name}-private-subnet"
    Owner = local.owner
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true

  tags = {
    Owner = local.owner
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public.id

  tags = {
    Name = "${local.project_name}-nat"
    Owner = local.owner
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${local.project_name}-private-rt"
    Owner = local.owner
  }
}

resource "aws_route_table_association" "private" {
  count = local.private_az_count

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
