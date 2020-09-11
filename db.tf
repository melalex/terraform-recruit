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
  security_group_names = []
  parameter_group_name = "default.mysql5.7"
}
