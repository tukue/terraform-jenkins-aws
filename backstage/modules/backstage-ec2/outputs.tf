output "instance_id" {
  value       = aws_instance.backstage.id
  description = "EC2 instance ID"
}

output "instance_ip" {
  value       = aws_instance.backstage.public_ip
  description = "Public IP address"
}

output "instance_hostname" {
  value       = aws_instance.backstage.public_dns
  description = "Public DNS hostname"
}

output "elastic_ip" {
  value       = aws_eip.backstage.public_ip
  description = "Elastic IP address"
}

output "backstage_url" {
  value       = "http://${aws_eip.backstage.public_ip}:3000"
  description = "Backstage portal URL"
}

output "ssh_command" {
  value       = "ssh -i your-key.pem ec2-user@${aws_eip.backstage.public_ip}"
  description = "SSH command to connect to instance"
}
