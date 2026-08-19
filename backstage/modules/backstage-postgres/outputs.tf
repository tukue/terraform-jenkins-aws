output "db_endpoint" {
  value       = aws_db_instance.backstage.endpoint
  description = "RDS endpoint address and port"
}

output "db_address" {
  value       = aws_db_instance.backstage.address
  description = "RDS endpoint address"
}

output "db_port" {
  value       = aws_db_instance.backstage.port
  description = "RDS port"
}

output "db_name" {
  value       = aws_db_instance.backstage.db_name
  description = "Database name"
}

output "db_username" {
  value       = aws_db_instance.backstage.username
  description = "Master username"
  sensitive   = true
}

output "db_resource_id" {
  value       = aws_db_instance.backstage.resource_id
  description = "The RDS resource ID"
}

output "db_security_group_id" {
  value       = aws_db_instance.backstage.vpc_security_group_ids[0]
  description = "Security group ID for the RDS instance"
}

output "db_connection_string" {
  value       = "postgresql://${var.user}:password@${aws_db_instance.backstage.address}:${aws_db_instance.backstage.port}/${var.db_name}"
  description = "PostgreSQL connection string (replace password)"
  sensitive   = true
}

output "master_user_secret_arn" {
  value       = try(aws_db_instance.backstage.master_user_secret[0].secret_arn, null)
  description = "ARN of the Secrets Manager secret containing the managed master user password"
  sensitive   = true
}

output "kms_key_arn" {
  value       = aws_kms_key.backstage_db.arn
  description = "ARN of the KMS key used for Backstage RDS encryption"
}
