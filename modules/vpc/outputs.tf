output "this_vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "this_nat_gateway_ip" {
  value = aws_eip.nat_gateway.public_ip
}
