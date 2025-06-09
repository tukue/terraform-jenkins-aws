locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = var.environment
    Project     = "Jenkins-AWS"
    ManagedBy   = "Terraform"
    Owner       = "DevOps-Team"
  }
}

# Create CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs/${var.environment}"
  retention_in_days = 30  # Adjust retention period as needed

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-vpc-flow-logs"
      Purpose = "VPC Flow Logs Storage"
    }
  )
}

# Create IAM role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-vpc-flow-logs-role"
      Purpose = "VPC Flow Logs IAM Role"
    }
  )
}

# Create IAM policy for VPC Flow Logs
resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
      }
    ]
  })
}

# Setup VPC
resource "aws_vpc" "dev_proj_1_vpc_eu_north_1" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = var.vpc_name
    }
  )
}

# Enable VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.dev_proj_1_vpc_eu_north_1.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-vpc-flow-logs"
      Purpose = "Network Traffic Monitoring"
    }
  )
}

# Setup public subnet
resource "aws_subnet" "dev_proj_1_public_subnets" {
  count             = length(var.cidr_public_subnet)
  vpc_id            = aws_vpc.dev_proj_1_vpc_eu_north_1.id
  cidr_block        = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-public-subnet-${count.index + 1}"
      Type = "Public"
    }
  )
}

# Setup private subnet
resource "aws_subnet" "dev_proj_1_private_subnets" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.dev_proj_1_vpc_eu_north_1.id
  cidr_block        = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-private-subnet-${count.index + 1}"
      Type = "Private"
    }
  )
}

# Setup Internet Gateway
resource "aws_internet_gateway" "dev_proj_1_public_internet_gateway" {
  vpc_id = aws_vpc.dev_proj_1_vpc_eu_north_1.id
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

# Public Route Table
resource "aws_route_table" "dev_proj_1_public_route_table" {
  vpc_id = aws_vpc.dev_proj_1_vpc_eu_north_1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_proj_1_public_internet_gateway.id
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-public-rt"
    }
  )
}

# Public Route Table and Public Subnet Association
resource "aws_route_table_association" "dev_proj_1_public_rt_subnet_association" {
  count          = length(aws_subnet.dev_proj_1_public_subnets)
  subnet_id      = aws_subnet.dev_proj_1_public_subnets[count.index].id
  route_table_id = aws_route_table.dev_proj_1_public_route_table.id
}

# Private Route Table
resource "aws_route_table" "dev_proj_1_private_subnets" {
  vpc_id = aws_vpc.dev_proj_1_vpc_eu_north_1.id
  #depends_on = [aws_nat_gateway.nat_gateway]
  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-private-rt"
    }
  )
}

# Private Route Table and private Subnet Association
resource "aws_route_table_association" "dev_proj_1_private_rt_subnet_association" {
  count          = length(aws_subnet.dev_proj_1_private_subnets)
  subnet_id      = aws_subnet.dev_proj_1_private_subnets[count.index].id
  route_table_id = aws_route_table.dev_proj_1_private_subnets.id
}

# Network ACL for additional security
resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.dev_proj_1_vpc_eu_north_1.id
  subnet_ids = concat(
    aws_subnet.dev_proj_1_public_subnets[*].id,
    aws_subnet.dev_proj_1_private_subnets[*].id
  )

  # Allow inbound HTTPS
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow inbound HTTP (for redirect to HTTPS)
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow inbound SSH from specific ranges (to be configured)
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.allowed_ssh_cidr  # This should be restricted in variables
    from_port  = 22
    to_port    = 22
  }

  # Allow all outbound
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.environment}-network-acl"
    }
  )
}