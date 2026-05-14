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

  egress {
    description = "Allow Jenkins outbound traffic to approved CIDR blocks"
    cidr_blocks = var.allowed_jenkins_egress_cidr_blocks
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.environment}-sg-ssh-http"
      Purpose = "Allow SSH, HTTP, and HTTPS traffic from specified ranges"
    }
  )
}

resource "aws_security_group" "alb_http_https" {
  name        = var.alb_sg_name
  description = "Allow public HTTP and HTTPS access to the Jenkins ALB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_alb_cidr_blocks) > 0 ? [1] : []
    content {
      description = "Allow HTTP from approved CIDR blocks"
      cidr_blocks = var.allowed_alb_cidr_blocks
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    }
  }

  dynamic "ingress" {
    for_each = length(var.allowed_alb_cidr_blocks) > 0 ? [1] : []
    content {
      description = "Allow HTTPS from approved CIDR blocks"
      cidr_blocks = var.allowed_alb_cidr_blocks
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    }
  }

  egress {
    description = "Allow outbound traffic to Jenkins targets inside the VPC"
    cidr_blocks = [var.vpc_cidr]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.environment}-sg-jenkins-alb"
      Purpose = "Public ALB access for Jenkins"
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

  ingress {
    description     = "Allow Jenkins from ALB"
    security_groups = [aws_security_group.alb_http_https.id]
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
  }

  egress {
    description = "Allow outbound traffic inside the VPC"
    cidr_blocks = [var.vpc_cidr]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = merge(
    local.common_tags,
    {
      Name    = "${var.environment}-sg-jenkins-8080"
      Purpose = "Allow Jenkins traffic on port 8080 from specified ranges"
    }
  )
}
