#!/bin/bash

# VPC Cleanup Script
# This script helps remove an unused VPC and its dependencies
# Usage: ./vpc-cleanup.sh [vpc-id] [region]

VPC_ID=$1
REGION=${2:-"eu-north-1"}  # Default to eu-north-1 if not specified

# Check if required parameters are provided
if [ -z "$VPC_ID" ]; then
    echo "Error: Missing VPC ID"
    echo "Usage: ./vpc-cleanup.sh [vpc-id] [region]"
    echo "Example: ./vpc-cleanup.sh vpc-1234567890abcdef0 eu-north-1"
    exit 1
fi

echo "Starting cleanup of VPC $VPC_ID in region $REGION..."

# 1. Delete NAT Gateways (if any)
echo "Looking for NAT Gateways..."
NAT_GATEWAYS=$(aws ec2 describe-nat-gateways --region $REGION --filter "Name=vpc-id,Values=$VPC_ID" --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text)
if [ ! -z "$NAT_GATEWAYS" ]; then
    for NAT_GATEWAY in $NAT_GATEWAYS; do
        echo "Deleting NAT Gateway $NAT_GATEWAY..."
        aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GATEWAY --region $REGION
    done
    echo "Waiting for NAT Gateways to be deleted (this may take a few minutes)..."
    sleep 60  # NAT Gateway deletion takes time
fi

# 2. Delete Load Balancers (if any)
echo "Looking for Load Balancers..."
LBS=$(aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[?VpcId=='$VPC_ID'].LoadBalancerArn" --output text)
if [ ! -z "$LBS" ]; then
    for LB in $LBS; do
        echo "Deleting Load Balancer $LB..."
        aws elbv2 delete-load-balancer --load-balancer-arn $LB --region $REGION
    done
    echo "Waiting for Load Balancers to be deleted..."
    sleep 30
fi

# 3. Terminate EC2 instances (if any)
echo "Looking for EC2 instances..."
INSTANCES=$(aws ec2 describe-instances --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" "Name=instance-state-name,Values=pending,running,stopping,stopped" --query 'Reservations[*].Instances[*].InstanceId' --output text)
if [ ! -z "$INSTANCES" ]; then
    echo "Terminating instances: $INSTANCES"
    aws ec2 terminate-instances --instance-ids $INSTANCES --region $REGION
    echo "Waiting for instances to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCES --region $REGION
fi

# 4. Delete Security Groups (except default)
echo "Looking for Security Groups..."
SGS=$(aws ec2 describe-security-groups --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
if [ ! -z "$SGS" ]; then
    for SG in $SGS; do
        echo "Deleting Security Group $SG..."
        aws ec2 delete-security-group --group-id $SG --region $REGION
    done
fi

# 5. Delete Subnets
echo "Looking for Subnets..."
SUBNETS=$(aws ec2 describe-subnets --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text)
if [ ! -z "$SUBNETS" ]; then
    for SUBNET in $SUBNETS; do
        echo "Deleting Subnet $SUBNET..."
        aws ec2 delete-subnet --subnet-id $SUBNET --region $REGION
    done
fi

# 6. Delete Route Tables (except main)
echo "Looking for Route Tables..."
RTS=$(aws ec2 describe-route-tables --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?Associations[?Main!=`true`]].RouteTableId' --output text)
if [ ! -z "$RTS" ]; then
    for RT in $RTS; do
        # First, disassociate any subnet associations
        ASSOCS=$(aws ec2 describe-route-tables --region $REGION --route-table-ids $RT --query 'RouteTables[0].Associations[?!Main].RouteTableAssociationId' --output text)
        for ASSOC in $ASSOCS; do
            echo "Disassociating Route Table Association $ASSOC..."
            aws ec2 disassociate-route-table --association-id $ASSOC --region $REGION
        done
        
        echo "Deleting Route Table $RT..."
        aws ec2 delete-route-table --route-table-id $RT --region $REGION
    done
fi

# 7. Detach and Delete Internet Gateway
echo "Looking for Internet Gateway..."
IGW=$(aws ec2 describe-internet-gateways --region $REGION --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[0].InternetGatewayId' --output text)
if [ ! -z "$IGW" ] && [ "$IGW" != "None" ]; then
    echo "Detaching Internet Gateway $IGW..."
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW --vpc-id $VPC_ID --region $REGION
    
    echo "Deleting Internet Gateway $IGW..."
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW --region $REGION
fi

# 8. Delete VPC Endpoints
echo "Looking for VPC Endpoints..."
ENDPOINTS=$(aws ec2 describe-vpc-endpoints --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'VpcEndpoints[*].VpcEndpointId' --output text)
if [ ! -z "$ENDPOINTS" ]; then
    echo "Deleting VPC Endpoints: $ENDPOINTS"
    aws ec2 delete-vpc-endpoints --vpc-endpoint-ids $ENDPOINTS --region $REGION
fi

# 9. Finally, delete the VPC
echo "Deleting VPC $VPC_ID..."
aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION

echo "VPC cleanup completed successfully"