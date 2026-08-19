output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "nat_gateway_ip" {
  description = "The public IP of the NAT Gateway"
  value       = length(aws_eip.nat) > 0 ? aws_eip.nat[0].public_ip : null
}

output "vpc_flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = length(aws_flow_log.this) > 0 ? aws_flow_log.this[0].id : null
}

output "vpc_flow_log_group_name" {
  description = "The CloudWatch Log Group name for VPC Flow Logs"
  value       = length(aws_cloudwatch_log_group.vpc_flow_logs) > 0 ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}
