output "this_nat_gateway_ip" {
  value = aws_eip.nat_gateway.public_ip
}

output "this_db_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "app_eip_public_ip" {
  value = aws_eip.app.public_ip
}

output "this_ssh_private_key_pem" {
  value = tls_private_key.this.private_key_pem
}

output "this_ssh_public_key_pem" {
  value = tls_private_key.this.public_key_pem
}
