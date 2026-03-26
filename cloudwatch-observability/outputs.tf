output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.this.dashboard_name
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.region}#dashboards:name=${aws_cloudwatch_dashboard.this.dashboard_name}"
}

output "cpu_alarm_name" {
  description = "CloudWatch alarm name for high CPU"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "status_check_alarm_name" {
  description = "CloudWatch alarm name for EC2 status check failures"
  value       = aws_cloudwatch_metric_alarm.status_check_failed.alarm_name
}
