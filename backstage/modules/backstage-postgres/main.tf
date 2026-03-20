resource "aws_db_subnet_group" "backstage" {
  name       = "${var.environment}-backstage-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-backstage-db-subnet-group"
    }
  )
}

resource "aws_db_instance" "backstage" {
  identifier     = "${var.environment}-backstage-db"
  engine         = "postgres"
  engine_version = "14.7"

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  iops              = 3000
  storage_encrypted = true
  kms_key_id        = aws_kms_key.backstage_db.arn

  db_name  = var.db_name
  username = var.user
  password = var.password

  instance_class = var.instance_class

  db_subnet_group_name   = aws_db_subnet_group.backstage.name
  vpc_security_group_ids = var.security_group_ids

  # Backup and maintenance
  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Multi-AZ and scaling
  multi_az            = var.multi_az
  publicly_accessible = var.publicly_accessible

  # Parameter group
  parameter_group_name = aws_db_parameter_group.backstage.name

  # Monitoring
  enabled_cloudwatch_logs_exports = ["postgresql"]
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.backstage_db_monitoring.arn

  # Snapshot and final snapshot
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.environment}-backstage-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Deletion protection
  deletion_protection = var.environment == "production" ? true : false

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-backstage-db"
    }
  )
}

resource "aws_db_parameter_group" "backstage" {
  name        = "${var.environment}-backstage-postgres14"
  family      = "postgres14"
  description = "PostgreSQL parameter group for Backstage"

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "ssl"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-backstage-postgres14"
    }
  )
}

# KMS key for encryption
resource "aws_kms_key" "backstage_db" {
  description             = "KMS key for Backstage RDS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-backstage-db-key"
    }
  )
}

resource "aws_kms_alias" "backstage_db" {
  name          = "alias/${var.environment}-backstage-db"
  target_key_id = aws_kms_key.backstage_db.key_id
}

# IAM role for RDS monitoring
resource "aws_iam_role" "backstage_db_monitoring" {
  name = "${var.environment}-backstage-db-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backstage_db_monitoring" {
  role       = aws_iam_role.backstage_db_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# CloudWatch alarm for DB CPU
resource "aws_cloudwatch_metric_alarm" "backstage_db_cpu" {
  alarm_name          = "${var.environment}-backstage-db-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when Backstage RDS CPU is > 80%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.backstage.id
  }

  tags = var.tags
}

# CloudWatch alarm for DB connections
resource "aws_cloudwatch_metric_alarm" "backstage_db_connections" {
  alarm_name          = "${var.environment}-backstage-db-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Alert when Backstage RDS connections are > 80"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.backstage.id
  }

  tags = var.tags
}
