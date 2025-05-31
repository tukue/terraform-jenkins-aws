# EC2 Cost Management Guide

This guide explains how to use the provided scripts to manage AWS EC2 costs by starting and stopping instances when not in use, and optionally detaching volumes.

## Why Manage EC2 Costs?

Running EC2 instances 24/7 can be expensive. For development and testing environments like Jenkins servers, you can save significant costs by:

1. Stopping instances when not in use (nights, weekends)
2. Detaching EBS volumes from stopped instances (optional, for additional savings)

## Available Scripts

Two versions of the cost management script are provided:

1. `ec2-cost-manager.sh` - Bash script for Linux/macOS users
2. `ec2-cost-manager.ps1` - PowerShell script for Windows users

## Prerequisites

- AWS CLI installed and configured with appropriate credentials
- Permissions to start/stop EC2 instances and attach/detach volumes

## Usage Instructions

### Bash Script (Linux/macOS)

```bash
./ec2-cost-manager.sh [start|stop] [instance-id] [region] [detach-volumes]
```

Example:
```bash
# Stop an instance and detach its volumes
./ec2-cost-manager.sh stop i-1234567890abcdef0 eu-north-1 true

# Start the instance and reattach volumes
./ec2-cost-manager.sh start i-1234567890abcdef0 eu-north-1 true
```

### PowerShell Script (Windows)

```powershell
.\ec2-cost-manager.ps1 -Action [start|stop] -InstanceId [instance-id] -Region [region] -DetachVolumes [true|false]
```

Example:
```powershell
# Stop an instance and detach its volumes
.\ec2-cost-manager.ps1 -Action stop -InstanceId i-1234567890abcdef0 -Region eu-north-1 -DetachVolumes $true

# Start the instance and reattach volumes
.\ec2-cost-manager.ps1 -Action start -InstanceId i-1234567890abcdef0 -Region eu-north-1 -DetachVolumes $true
```

## Scheduling with Cron/Task Scheduler

### Linux/macOS (Cron)

Add entries to your crontab to automatically stop instances at night and start them in the morning:

```bash
# Edit crontab
crontab -e

# Add these lines (stop at 8 PM, start at 8 AM on weekdays)
0 20 * * 1-5 /path/to/ec2-cost-manager.sh stop i-1234567890abcdef0 eu-north-1 true
0 8 * * 1-5 /path/to/ec2-cost-manager.sh start i-1234567890abcdef0 eu-north-1 true
```

### Windows (Task Scheduler)

1. Open Task Scheduler
2. Create a new task
3. Set triggers (e.g., daily at 8 PM)
4. Add action: Start a program
   - Program/script: `powershell.exe`
   - Arguments: `-ExecutionPolicy Bypass -File "C:\path\to\ec2-cost-manager.ps1" -Action stop -InstanceId i-1234567890abcdef0 -Region eu-north-1 -DetachVolumes $true`

## Important Notes

1. **Root Volume**: The script will not detach the root volume of an instance.
2. **Data Persistence**: Ensure any important data is saved before stopping instances.
3. **Volume Mapping**: When reattaching volumes, device names may change. The script attempts to handle this but may require manual intervention in some cases.
4. **Cost Savings**: Stopping an EC2 instance eliminates compute charges, but you still pay for attached EBS volumes and allocated Elastic IPs.

## Potential Monthly Savings

Based on your current costs:
- EC2 Compute: $15.29/month
- If used 40 hours/week instead of 168 hours/week: ~$10.90/month savings (71% reduction)
- Additional savings from detaching unused volumes

## Troubleshooting

If volumes don't reattach properly:
1. Check the volume list file (`./<instance-id>_volumes.txt`)
2. Manually attach volumes using the AWS Console or CLI
3. Ensure proper permissions in your IAM policy