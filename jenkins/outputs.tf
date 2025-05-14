output "ssh_connection_string_for_ec2" {
  value = format("%s%s", "ssh -i /Users/tukue/.ssh/aws_ec2_terraform ubuntu@", aws_instance.jenkins_ec2_instance_ip.public_ip)
}

output "jenkins_ec2_instance_ip" {
  value = aws_instance.jenkins_ec2_instance_ip.id
}

output "dev_proj_1_ec2_instance_public_ip" {
  value = aws_instance.jenkins_ec2_instance_ip.public_ip
}