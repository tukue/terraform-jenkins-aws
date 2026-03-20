output "instance_id" {
  description = "Grafana EC2 instance ID"
  value       = aws_instance.grafana.id
}

output "instance_public_ip" {
  description = "Public IP address for the Grafana host"
  value       = aws_instance.grafana.public_ip
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "http://${aws_instance.grafana.public_ip}:3000"
}

output "security_group_id" {
  description = "Security group ID for the Grafana host"
  value       = aws_security_group.grafana.id
}
