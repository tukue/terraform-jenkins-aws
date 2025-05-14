output "dev_proj_1_vpc_id" {
  value = aws_vpc.dev_proj_1_vpc_eu_north_1.id
}

output "dev_proj_1_public_subnets" {
  value = aws_subnet.dev_proj_1_public_subnets.*.id
}

output "public_subnet_cidr_block" {
  value = aws_subnet.dev_proj_1_public_subnets.*.cidr_block
}