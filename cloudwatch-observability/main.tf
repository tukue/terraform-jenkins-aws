data "aws_region" "current" {}

locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Service     = "observability"
      ManagedBy   = "terraform"
    }
  )

  dashboard_name = "${var.environment}-jenkins-observability"

  dashboard_markdown_lines = concat(
    [
      "# ${var.instance_name} Observability",
      "",
      "- Environment: ${var.environment}",
      "- Region: ${data.aws_region.current.region}",
      "- Instance ID: ${var.instance_id}"
    ],
    var.instance_public_ip != "" ? ["- Public IP: ${var.instance_public_ip}"] : []
  )
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.environment}-jenkins-cpu-high"
  alarm_description   = "${var.instance_name} CPU utilization is above the warning threshold"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-jenkins-cpu-high"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  alarm_name          = "${var.environment}-jenkins-status-check-failed"
  alarm_description   = "${var.instance_name} instance status checks are failing"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.status_check_threshold
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = var.instance_id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-jenkins-status-check-failed"
    }
  )
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = local.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 4
        properties = {
          markdown = join("\n", local.dashboard_markdown_lines)
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 4
        width  = 12
        height = 6
        properties = {
          title  = "${var.instance_name} CPU Utilization"
          region = data.aws_region.current.region
          stat   = "Average"
          period = 300
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              var.instance_id
            ]
          ]
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 4
        width  = 12
        height = 6
        properties = {
          title  = "${var.instance_name} Status Checks"
          region = data.aws_region.current.region
          stat   = "Maximum"
          period = 300
          metrics = [
            [
              "AWS/EC2",
              "StatusCheckFailed",
              "InstanceId",
              var.instance_id
            ]
          ]
          yAxis = {
            left = {
              min = 0
              max = 1
            }
          }
        }
      }
    ]
  })
}
