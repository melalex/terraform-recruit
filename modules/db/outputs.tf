output "this_db_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "this_db_host" {
  value = aws_db_instance.this.address
}

output "this_db_port" {
  value = aws_db_instance.this.port
}