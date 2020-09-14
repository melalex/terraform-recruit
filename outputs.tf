output "vpc_nat_gateway_ip" {
  value = module.vpc.this_nat_gateway_ip
}

output "alb_dns_name" {
  value = module.app.this_alb_dns_name
}

output "db_endpoint" {
  value = module.db.this_db_endpoint
}

output "app_eip_public_ip" {
  value = module.app.this_eip_public_ip
}

output "app_ssh_private_key_pem" {
  value = module.app.this_ssh_private_key_pem
}

output "app_ssh_public_key_pem" {
  value = module.app.this_ssh_public_key_pem
}
