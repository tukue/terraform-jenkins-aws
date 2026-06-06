output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_name" {
  description = "The name tag of the VPC"
  value       = var.vpc_name
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway (if enabled)"
  value       = length(aws_eip.nat) > 0 ? aws_eip.nat[0].public_ip : null
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (if enabled)"
  value       = length(aws_nat_gateway.this) > 0 ? aws_nat_gateway.this[0].id : null
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log (if enabled)"
  value       = length(aws_flow_log.this) > 0 ? aws_flow_log.this[0].id : null
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch Log Group name for VPC Flow Logs"
  value       = length(aws_cloudwatch_log_group.vpc_flow_logs) > 0 ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}

output "network_acl_id" {
  description = "ID of the Network ACL (if enabled)"
  value       = length(aws_network_acl.this) > 0 ? aws_network_acl.this[0].id : null
}
