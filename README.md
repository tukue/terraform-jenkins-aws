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
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Create and switch to a workspace:
   Terraform workspaces allow you to manage multiple environments (e.g., `dev`, `QA`, `production`) using the same configuration.

   - Create a workspace for `dev`:
     ```bash
     terraform workspace new dev
     ```

   - Create a workspace for `QA`:
     ```bash
     terraform workspace new QA
     ```

   - Create a workspace for `production`:
     ```bash
     terraform workspace new production
     ```

   - Switch between workspaces:
     ```bash
     terraform workspace select <workspace-name>
     ```

4. Use environment-specific `.tfvars` files:
   Each environment has its own `.tfvars` file to manage configurations. Use the `-var-file` flag to specify the appropriate file when running Terraform commands.

   - For `dev`:
     ```bash
     terraform plan -var-file="terraform.tfvars"
     terraform apply -var-file="terraform.tfvars"
     ```

   - For `QA`:
     ```bash
     terraform plan -var-file="terraform.qa.tfvars"
     terraform apply -var-file="terraform.qa.tfvars"
     ```

   - For `production`:
     ```bash
     terraform plan -var-file="terraform.prod.tfvars"
     terraform apply -var-file="terraform.prod.tfvars"
     ```

5. Plan the infrastructure:
   ```bash
   terraform plan -var-file="terraform.<env>.tfvars"
   ```

6. Apply the configuration:
   ```bash
   terraform apply -var-file="terraform.<env>.tfvars"
   ```

   Replace `<env>` with `tfvars`, `qa.tfvars`, or `prod.tfvars` based on the environment.

## Outputs

After applying the configuration, Terraform will output the following:

- Jenkins EC2 instance public IP.
- Load balancer DNS name.
- Hosted zone ID.
- ACM certificate ARN.

## Notes

- Ensure that `.tfvars` files are added to `.gitignore` to avoid committing sensitive data.
- Use the `terraform.tfvars` file for `dev`, `terraform.qa.tfvars` for `QA`, and `terraform.prod.tfvars` for `production` environments.