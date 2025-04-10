# Terraform Jenkins AWS

This repository contains Terraform configurations to automate the deployment of a Jenkins server on AWS. It provisions infrastructure such as VPC, EC2 instances, S3 backend for state management, and Route 53 for domain configuration.

## Features

- **Jenkins Deployment**: Automates the setup of a Jenkins server on an EC2 instance.
- **S3 Backend**: Stores Terraform state files securely in an S3 bucket.
- **Networking**: Configures VPC, subnets, and security groups.
- **Load Balancer**: Sets up an Application Load Balancer (ALB) for traffic routing.
- **Domain Management**: Integrates with Route 53 for DNS and SSL certificate management.

## Prerequisites

- AWS account with necessary permissions.
- Terraform installed on your local machine.
- SSH key pair for accessing the EC2 instance.

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/tukue/terraform-jenkins-aws.git
   cd terraform-jenkins-aws
