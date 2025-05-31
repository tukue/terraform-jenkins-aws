#!/bin/bash

# EC2 Instance Scheduler Script
# This script starts or stops EC2 instances based on the provided action
# Usage: ./ec2-scheduler.sh [start|stop] [instance-id] [region]

ACTION=$1
INSTANCE_ID=$2
REGION=${3:-"eu-north-1"}  # Default to eu-north-1 if not specified

# Check if required parameters are provided
if [ -z "$ACTION" ] || [ -z "$INSTANCE_ID" ]; then
    echo "Error: Missing required parameters"
    echo "Usage: ./ec2-scheduler.sh [start|stop] [instance-id] [region]"
    exit 1
fi

# Validate action parameter
if [ "$ACTION" != "start" ] && [ "$ACTION" != "stop" ]; then
    echo "Error: Invalid action. Use 'start' or 'stop'"
    exit 1
fi

# Execute the AWS CLI command to start or stop the instance
if [ "$ACTION" == "start" ]; then
    echo "Starting EC2 instance $INSTANCE_ID in region $REGION..."
    aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION
    
    # Wait for the instance to be running
    echo "Waiting for instance to be in running state..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION
    
    # Get the public IP address
    PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    echo "Instance is now running with IP: $PUBLIC_IP"
else
    echo "Stopping EC2 instance $INSTANCE_ID in region $REGION..."
    aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION
    
    # Wait for the instance to be stopped
    echo "Waiting for instance to be in stopped state..."
    aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID --region $REGION
    echo "Instance has been stopped successfully"
fi

echo "Operation completed successfully"