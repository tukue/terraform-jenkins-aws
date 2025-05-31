# EC2 Instance Scheduler

This guide explains how to use the provided scripts to start and stop your EC2 instances to reduce AWS costs.

## Why Schedule EC2 Instances?

EC2 instances incur charges when they're running, even if you're not actively using them. By stopping instances when they're not needed (e.g., nights, weekends), you can significantly reduce your AWS bill.

## Available Scripts

Two scripts are provided for different operating systems:

1. `ec2-scheduler.sh` - For Linux/macOS users
2. `schedule-ec2.ps1` - For Windows users

## Prerequisites

- AWS CLI installed and configured with appropriate credentials
- Instance ID of your EC2 instance(s)
- AWS region where your instance is located

## Usage Instructions

### For Linux/macOS Users

1. Make the script executable:
   ```bash
   chmod +x ec2-scheduler.sh
   ```

2. To start an instance:
   ```bash
   ./ec2-scheduler.sh start i-0123456789abcdef0 eu-north-1
   ```

3. To stop an instance:
   ```bash
   ./ec2-scheduler.sh stop i-0123456789abcdef0 eu-north-1
   ```

### For Windows Users

1. To start an instance:
   ```powershell
   .\schedule-ec2.ps1 -Action start -InstanceId i-0123456789abcdef0 -Region eu-north-1
   ```

2. To stop an instance:
   ```powershell
   .\schedule-ec2.ps1 -Action stop -InstanceId i-0123456789abcdef0 -Region eu-north-1
   ```

## Setting Up Scheduled Tasks

### On Windows

1. Open Task Scheduler
2. Create a new task
3. Set triggers (e.g., daily at 7 PM to stop instances)
4. Add an action to run PowerShell with the script and parameters
5. Save the task

Example command for the task:
```
powershell.exe -ExecutionPolicy Bypass -File "C:\Users\tukue\terraform-jenkins-aws\schedule-ec2.ps1" -Action stop -InstanceId i-0123456789abcdef0 -Region eu-north-1
```

### On Linux/macOS

1. Edit the crontab:
   ```bash
   crontab -e
   ```

2. Add entries for starting and stopping:
   ```
   # Start instance at 8 AM on weekdays
   0 8 * * 1-5 /path/to/ec2-scheduler.sh start i-0123456789abcdef0 eu-north-1

   # Stop instance at 7 PM on weekdays
   0 19 * * 1-5 /path/to/ec2-scheduler.sh stop i-0123456789abcdef0 eu-north-1
   ```

## Cost Savings Estimate

Based on your current EC2 costs of $15.29 per month, you could save approximately:

- 50% ($7.65/month) by running instances only during business hours on weekdays
- 70% ($10.70/month) by running instances only when actively needed

## Finding Your Instance ID

To find your EC2 instance ID:

1. Log in to the AWS Management Console
2. Navigate to EC2 > Instances
3. Copy the Instance ID from the list (format: i-0123456789abcdef0)

## Troubleshooting

- Ensure AWS CLI is properly configured with `aws configure`
- Verify you have permissions to start/stop EC2 instances
- Check that the instance ID and region are correct