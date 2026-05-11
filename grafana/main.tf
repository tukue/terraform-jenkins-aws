resource "aws_security_group" "grafana" {
  name        = "${var.environment}-grafana-sg"
  description = "Security group for Grafana"
  vpc_id      = var.vpc_id

  ingress {
    description = "Grafana UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-grafana-sg"
      Environment = var.environment
      Service     = "grafana"
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_instance" "grafana" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.grafana.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/user_data.sh", {
    grafana_version = var.grafana_version
    admin_user      = var.admin_user
    admin_password  = var.admin_password
    prometheus_url  = var.prometheus_url
  })
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-grafana"
      Environment = var.environment
      Service     = "grafana"
      ManagedBy   = "terraform"
    }
  )
}
