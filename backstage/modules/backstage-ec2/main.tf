# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# User data script for Backstage setup
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host             = var.db_host
    db_port             = var.db_port
    db_name             = var.db_name
    db_user             = var.db_user
    db_password         = var.db_password
    github_client_id    = var.github_client_id
    github_client_secret = var.github_client_secret
    github_token        = var.github_token
    backstage_version   = var.backstage_version
  }))
}

resource "aws_instance" "backstage" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  
  key_name = var.key_name != "" ? var.key_name : null
  
  # Root volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
  }
  
  # User data
  user_data            = local.user_data
  user_data_replace_on_change = true
  
  # Monitoring
  monitoring = true
  
  # Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-backstage"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for stable IP
resource "aws_eip" "backstage" {
  instance = aws_instance.backstage.id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-backstage-eip"
    }
  )

  depends_on = [aws_instance.backstage]
}

# CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "backstage_cpu" {
  alarm_name          = "${var.environment}-backstage-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when Backstage CPU is > 80%"

  dimensions = {
    InstanceId = aws_instance.backstage.id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "backstage_status" {
  alarm_name          = "${var.environment}-backstage-status-check"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Alert when Backstage instance status check fails"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.backstage.id
  }

  tags = var.tags
}
