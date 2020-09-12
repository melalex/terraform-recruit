output "this_alb_dns_name" {
  value = aws_alb.this.dns_name
}

output "this_eip_public_ip" {
  value = aws_eip.this.public_ip
}

output "this_ssh_private_key_pem" {
  value = tls_private_key.this.private_key_pem
}

output "this_ssh_public_key_pem" {
  value = tls_private_key.this.public_key_pem
}
