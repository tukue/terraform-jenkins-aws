locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = var.environment
    Project     = "Jenkins-AWS"
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
  }
}

resource "aws_security_group" "ec2_sg_ssh_http" {
  name        = var.ec2_sg_name
  description = "Enable the Port 22(SSH) & Port 80(http)"
  vpc_id      = var.vpc_id

  # ssh for terraform remote exec
  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidr_blocks) > 0 ? [1] : []
    content {
      description = "Allow remote SSH from specified ranges"
      cidr_blocks = var.allowed_ssh_cidr_blocks
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
    }
  }

  # enable http
  dynamic "ingress" {
    for_each = length(var.allowed_http_cidr_blocks) > 0 ? [1] : []
    content {
      description = "Allow HTTP request from specified ranges"
      cidr_blocks = var.allowed_http_cidr_blocks
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    }
  }

  # enable https
  dynamic "ingress" {
    for_each = length(var.allowed_http_cidr_blocks) > 0 ? [1] : []
    content {
      description = "Allow HTTPS request from specified ranges"
      cidr_blocks = var.allowed_http_cidr_blocks
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    }
  }

  #Outgoing request
  egress {
    description = "Allow outgoing request"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # This is generally acceptable for outbound traffic
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-sg-ssh-http"
      Purpose = "Allow SSH, HTTP, and HTTPS traffic from specified ranges"
    }
  )
}

resource "aws_security_group" "ec2_jenkins_port_8080" {
  name        = var.ec2_jenkins_sg_name
  description = "Enable the Port 8080 for jenkins"
  vpc_id      = var.vpc_id

  # jenkins access
  dynamic "ingress" {
    for_each = length(var.allowed_jenkins_cidr_blocks) > 0 ? [1] : []
    content {
      description = "Allow 8080 port to access jenkins from specified ranges"
      cidr_blocks = var.allowed_jenkins_cidr_blocks
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
    }
  }

  # Add egress rule for Jenkins security group
  egress {
    description = "Allow outgoing request"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # This is generally acceptable for outbound traffic
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-sg-jenkins-8080"
      Purpose = "Allow Jenkins traffic on port 8080 from specified ranges"
    }
  )
}