#!/bin/bash

# EC2 Cost Manager Script
# This script manages EC2 instances to reduce costs by:
# 1. Starting/stopping instances
# 2. Detaching volumes when stopping (optional)
# 3. Disassociating Elastic IP when stopping (optional)
# Usage: ./ec2-cost-manager.sh [start|stop] [instance-id] [region] [detach-volumes] [manage-eip]

ACTION=$1
INSTANCE_ID=$2
REGION=${3:-"eu-north-1"}  # Default to eu-north-1 if not specified
DETACH_VOLUMES=${4:-"false"}  # Whether to detach volumes when stopping
MANAGE_EIP=${5:-"false"}  # Whether to disassociate/associate Elastic IP

# Check if required parameters are provided
if [ -z "$ACTION" ] || [ -z "$INSTANCE_ID" ]; then
    echo "Error: Missing required parameters"
    echo "Usage: ./ec2-cost-manager.sh [start|stop] [instance-id] [region] [detach-volumes]"
    echo "Example: ./ec2-cost-manager.sh stop i-1234567890abcdef0 eu-north-1 true"
    exit 1
fi

# Validate action parameter
if [ "$ACTION" != "start" ] && [ "$ACTION" != "stop" ]; then
    echo "Error: Invalid action. Use 'start' or 'stop'"
    exit 1
fi

# Function to get volume IDs attached to an instance
get_attached_volumes() {
    aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --region $REGION \
        --query "Reservations[0].Instances[0].BlockDeviceMappings[*].Ebs.VolumeId" \
        --output text
}

# Function to detach volumes
detach_volumes() {
    local volumes=$1
    for volume_id in $volumes; do
        echo "Detaching volume $volume_id..."
        aws ec2 detach-volume \
            --volume-id $volume_id \
            --region $REGION
        
        # Wait for volume to be available
        echo "Waiting for volume $volume_id to be available..."
        aws ec2 wait volume-available \
            --volume-ids $volume_id \
            --region $REGION
    done
}

# Function to attach volumes
attach_volumes() {
    local volumes=$1
    local device_names=("xvdf" "xvdg" "xvdh" "xvdi" "xvdj")
    local index=0
    
    for volume_id in $volumes; do
        echo "Attaching volume $volume_id to instance $INSTANCE_ID..."
        aws ec2 attach-volume \
            --volume-id $volume_id \
            --instance-id $INSTANCE_ID \
            --device /dev/${device_names[$index]} \
            --region $REGION
        
        # Wait for volume to be in-use
        echo "Waiting for volume $volume_id to be attached..."
        aws ec2 wait volume-in-use \
            --volume-ids $volume_id \
            --region $REGION
        
        ((index++))
    done
}

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
    
    # If volumes were detached, we need to reattach them
    if [ "$DETACH_VOLUMES" == "true" ]; then
        # Check if there's a saved list of volumes
        if [ -f "./${INSTANCE_ID}_volumes.txt" ]; then
            VOLUMES=$(cat ./${INSTANCE_ID}_volumes.txt)
            echo "Found saved volume list: $VOLUMES"
            attach_volumes "$VOLUMES"
            rm ./${INSTANCE_ID}_volumes.txt
        else
            echo "No saved volume list found. Volumes may need to be attached manually."
        fi
    fi
    
    # If we're managing Elastic IPs, reassociate the IP
    if [ "$MANAGE_EIP" == "true" ]; then
        # Check if there's a saved Elastic IP allocation ID
        if [ -f "./${INSTANCE_ID}_eip.txt" ]; then
            ALLOCATION_ID=$(cat ./${INSTANCE_ID}_eip.txt)
            echo "Found saved Elastic IP allocation ID: $ALLOCATION_ID"
            
            echo "Associating Elastic IP with instance $INSTANCE_ID..."
            aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $ALLOCATION_ID --region $REGION
            
            # Get the public IP address after association
            PUBLIC_IP=$(aws ec2 describe-addresses --region $REGION --allocation-ids $ALLOCATION_ID --query 'Addresses[0].PublicIp' --output text)
            echo "Elastic IP $PUBLIC_IP associated successfully"
            
            rm ./${INSTANCE_ID}_eip.txt
        else
            echo "No saved Elastic IP information found. IP may need to be associated manually."
        fi
    fi
else
    # If we're stopping and need to detach volumes, save the list first
    if [ "$DETACH_VOLUMES" == "true" ]; then
        VOLUMES=$(get_attached_volumes)
        echo "Saving list of attached volumes: $VOLUMES"
        echo "$VOLUMES" > ./${INSTANCE_ID}_volumes.txt
    fi
    
    echo "Stopping EC2 instance $INSTANCE_ID in region $REGION..."
    aws ec2 stop-instances --instance-ids $INSTANCE_ID --region $REGION
    
    # Wait for the instance to be stopped
    echo "Waiting for instance to be in stopped state..."
    aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID --region $REGION
    echo "Instance has been stopped successfully"
    
    # Detach volumes if requested
    if [ "$DETACH_VOLUMES" == "true" ]; then
        VOLUMES=$(get_attached_volumes)
        if [ ! -z "$VOLUMES" ]; then
            echo "Detaching volumes: $VOLUMES"
            detach_volumes "$VOLUMES"
        else
            echo "No volumes to detach"
        fi
    fi
    
    # Disassociate Elastic IP if requested
    if [ "$MANAGE_EIP" == "true" ]; then
        # Get association ID for any EIP attached to the instance
        ASSOCIATION_ID=$(aws ec2 describe-addresses --region $REGION --filters "Name=instance-id,Values=$INSTANCE_ID" --query 'Addresses[0].AssociationId' --output text)
        
        if [ ! -z "$ASSOCIATION_ID" ] && [ "$ASSOCIATION_ID" != "None" ]; then
            # Get the allocation ID and public IP for later use
            ALLOCATION_ID=$(aws ec2 describe-addresses --region $REGION --filters "Name=instance-id,Values=$INSTANCE_ID" --query 'Addresses[0].AllocationId' --output text)
            PUBLIC_IP=$(aws ec2 describe-addresses --region $REGION --filters "Name=instance-id,Values=$INSTANCE_ID" --query 'Addresses[0].PublicIp' --output text)
            
            echo "Saving Elastic IP information: $PUBLIC_IP (Allocation ID: $ALLOCATION_ID)"
            echo "$ALLOCATION_ID" > ./${INSTANCE_ID}_eip.txt
            
            echo "Disassociating Elastic IP $PUBLIC_IP from instance $INSTANCE_ID..."
            aws ec2 disassociate-address --association-id $ASSOCIATION_ID --region $REGION
            echo "Elastic IP disassociated successfully"
        else
            echo "No Elastic IP associated with this instance"
        fi
    fi
fi

echo "Operation completed successfully"