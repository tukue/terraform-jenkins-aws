output "id" {
  description = "The ID of the security group"
  value       = aws_security_group.this.id
}

output "arn" {
  description = "The ARN of the security group"
  value       = aws_security_group.this.arn
}

output "name" {
  description = "The name of the security group"
  value       = aws_security_group.this.name
}
