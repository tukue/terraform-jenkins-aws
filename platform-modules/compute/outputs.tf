output "jenkins_ec2_instance_ip" {
  value = aws_instance.jenkins_ec2_instance_ip.id
}

output "jenkins_instance_id" {
  description = "EC2 instance ID for Jenkins"
  value       = aws_instance.jenkins_ec2_instance_ip.id
}

output "dev_proj_1_ec2_instance_public_ip" {
  value = aws_instance.jenkins_ec2_instance_ip.public_ip
}

output "jenkins_private_ip" {
  value = aws_instance.jenkins_ec2_instance_ip.private_ip
}
