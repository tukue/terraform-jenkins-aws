# VPC outputs
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr_block
  description = "VPC CIDR block"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnets
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs"
}

# RDS outputs
output "rds_endpoint" {
  value       = module.backstage_postgres.db_endpoint
  description = "RDS endpoint (host:port)"
}

output "rds_host" {
  value       = module.backstage_postgres.db_address
  description = "RDS host address"
}

output "rds_port" {
  value       = module.backstage_postgres.db_port
  description = "RDS port"
}

output "rds_database" {
  value       = module.backstage_postgres.db_name
  description = "RDS database name"
}

# EC2 outputs
output "backstage_instance_id" {
  value       = module.backstage_ec2.instance_id
  description = "EC2 instance ID"
}

output "backstage_public_ip" {
  value       = module.backstage_ec2.instance_ip
  description = "Public IP address"
}

output "backstage_elastic_ip" {
  value       = module.backstage_ec2.elastic_ip
  description = "Elastic IP address"
}

output "backstage_url" {
  value       = module.backstage_ec2.backstage_url
  description = "Backstage portal URL"
}

output "backstage_ssh_command" {
  value       = module.backstage_ec2.ssh_command
  description = "SSH command to connect to Backstage instance"
}

output "backstage_dns_name" {
  value       = module.backstage_ec2.instance_hostname
  description = "Public DNS hostname"
}

# Connection information
output "connection_info" {
  value = {
    backstage_url  = module.backstage_ec2.backstage_url
    ssh_command    = module.backstage_ec2.ssh_command
    rds_endpoint   = module.backstage_postgres.db_endpoint
    rds_username   = module.backstage_postgres.db_username
  }
  description = "Complete connection information"
  sensitive   = false
}
