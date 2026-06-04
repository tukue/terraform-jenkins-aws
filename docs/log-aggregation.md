# Log Aggregation

## Architecture

CloudWatch Logs collect from all platform components. Logs are exported to S3 for long-term storage and queried via CloudWatch Logs Insights or Athena.

## Log Sources

| Source | Log Type | Retention | Destination |
|--------|----------|-----------|-------------|
| Jenkins (EC2) | Application, access, audit | 30 days hot / 1 year cold | CloudWatch + S3 |
| ALB | Access logs | 30 days | S3 |
| Backstage | App, auth, scaffolder | 14 days | CloudWatch |
| VPC | Flow logs | 30 days | CloudWatch + S3 |
| CloudTrail | API activity | 90 days | S3 + Athena |

## CloudWatch Log Configuration

### Common Queries

**Jenkins Errors (last 24h)**
```
fields @timestamp, @message
| filter @logStream like /jenkins/
| filter @message like /(?i)(error|exception|failed)/
| sort @timestamp desc
| limit 50
```

**ALB 5xx Responses (last 4h)**
```
fields @timestamp, elb_status_code, request_url
| filter elb_status_code >= 500
| sort @timestamp desc
| limit 100
```

**VPC Flow Logs (top talkers)**
```
stats sum(bytes) as bytesTransferred by srcAddr, dstAddr
| sort bytesTransferred desc
| limit 20
```

## Log Export

```hcl
resource "aws_s3_bucket" "log_archive" {
  bucket = "platform-logs-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_lifecycle_configuration" "log_archive" {
  bucket = aws_s3_bucket.log_archive.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = 365
    }
  }
}
```

## Alerting on Log Patterns

| Pattern | Severity | Action |
|---------|----------|--------|
| Repeated Jenkins OutOfMemoryError | Critical | PagerDuty incident |
| ALB 5xx > 1% in 5 minutes | Warning | Slack notification |
| Unauthorized SSH attempts | Warning | Security review |
| Terraform apply failures | Warning | Platform team notification |

## Athena Setup (audit queries)

1. Export CloudTrail and VPC flow logs to S3
2. Create Athena table partitioned by date
3. Query with standard SQL for compliance audits
