output "state_bucket_name" {
  description = "S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_logs_bucket_name" {
  description = "S3 bucket used for Terraform state access logs"
  value       = aws_s3_bucket.terraform_state_logs.id
}

output "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "kms_key_arn" {
  description = "KMS key ARN used for backend encryption"
  value       = aws_kms_key.terraform_state.arn
}
