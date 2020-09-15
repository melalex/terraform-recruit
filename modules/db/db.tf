resource "aws_security_group" "db" {
  name = "${var.project_name}-db-sg"

  description = "Allow only MySQL connection."
  vpc_id = var.vpc_id

  # Only MySQL in
  ingress {
    from_port = var.db_port
    to_port = var.db_port
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_db_subnet_group" "this" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
    Owner = var.owner
    Project = var.project_name
  }
}

resource "aws_db_instance" "this" {
  allocated_storage = 20
  name = var.db_name
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  port = var.db_port
  username = var.db_user
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.this.id
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot = true

  vpc_security_group_ids = [
    aws_security_group.db.id
  ]

  tags = {
    Name = "${var.project_name}-db"
    Owner = var.owner
    Project = var.project_name
  }
}
