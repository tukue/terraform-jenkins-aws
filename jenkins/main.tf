locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = var.environment
    Project     = "Jenkins-AWS"
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
  }
}

resource "aws_instance" "jenkins_ec2_instance_ip" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = merge(
    local.common_tags,
    {
      Name = var.tag_name
      Service = "Jenkins"
      AutoStop = "true"  # Can be used with AWS Lambda to stop instance during non-work hours
    }
  )
  key_name                    = aws_key_pair.jenkins_ec2_instance_public_key.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.sg_for_jenkins
  associate_public_ip_address = var.enable_public_ip_address
  monitoring                  = true  # Enable detailed monitoring

  # Enable EBS optimization if the instance type supports it
  ebs_optimized = true

  # Root volume encryption
  root_block_device {
    encrypted   = true
    volume_type = "gp3"  # Using gp3 for better performance and cost
  }

  user_data = var.user_data_install_jenkins

  metadata_options {
    http_endpoint               = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens                 = "required" # Require the use of IMDSv2 tokens
    http_put_response_hop_limit = 1         # Restrict IMDS to one hop
  }

  # Enable termination protection
  disable_api_termination = true

  # Enable detailed monitoring
  credit_specification {
    cpu_credits = "standard"  # Use standard CPU credits to avoid unexpected costs
  }
}

resource "aws_key_pair" "jenkins_ec2_instance_public_key" {
  key_name   = "aws_ec2_terraform"
  public_key = var.public_key
  
  tags = merge(
    local.common_tags,
    {
      Purpose = "Jenkins EC2 SSH access"
    }
  )
}

resource "null_resource" "ansible_provisioner" {
  count = var.run_ansible ? 1 : 0
  
  depends_on = [aws_instance.jenkins_ec2_instance_ip]

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/inventory/aws_ec2.yml ../ansible/playbooks/jenkins-setup.yml"
    
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}