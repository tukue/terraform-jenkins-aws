# Terraform Jenkins AWS

This repository contains Terraform configurations to automate the deployment of a Jenkins server on AWS. It provisions infrastructure such as VPC, EC2 instances, S3 backend for state management, and Route 53 for domain configuration.

---

## Features

- **Jenkins Deployment**: Automates the setup of a Jenkins server on an EC2 instance.
- **S3 Backend**: Stores Terraform state files securely in an S3 bucket.
- **Networking**: Configures VPC, subnets, and security groups.
- **Load Balancer**: Sets up an Application Load Balancer (ALB) for traffic routing.
- **Domain Management**: Integrates with Route 53 for DNS and SSL certificate management.

---

## Prerequisites

- AWS account with necessary permissions.
- Terraform installed on your local machine.
- SSH key pair for accessing the EC2 instance.

---

## Backend Configuration

This project uses an S3 bucket as the backend to store Terraform state files securely. Each environment (`dev`, `QA`, `production`) has its own backend configuration file.

### Backend Configuration Files
- `backend-config-dev.hcl`: Backend configuration for the `dev` environment.
- `backend-config-qa.hcl`: Backend configuration for the `QA` environment.
- `backend-config-prod.hcl`: Backend configuration for the `production` environment.

### Initializing the Backend
To initialize the backend for a specific environment, use the `-backend-config` flag with the `terraform init` command.

#### For `dev` Environment:
```bash
terraform init -backend-config="backend-config-dev.hcl"
```

#### For `QA` Environment:
```bash
terraform init -backend-config="backend-config-qa.hcl"
```

#### For `Production` Environment:
```bash
terraform init -backend-config="backend-config-prod.hcl"
```

---

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/tukue/terraform-jenkins-aws.git
   cd terraform-jenkins-aws
   ```

2. Create and switch to a workspace:
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

3. Use environment-specific `.tfvars` files:
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

4. Plan the infrastructure:
   ```bash
   terraform plan -var-file="terraform.<env>.tfvars"
   ```

5. Apply the configuration:
   ```bash
   terraform apply -var-file="terraform.<env>.tfvars"
   ```

   Replace `<env>` with `tfvars`, `qa.tfvars`, or `prod.tfvars` based on the environment.

---

## Outputs

After applying the configuration, Terraform will output the following:

- Jenkins EC2 instance public IP.
- Load balancer DNS name.
- Hosted zone ID.
- ACM certificate ARN.

---

## Notes

- Ensure that `.tfvars` files are added to `.gitignore` to avoid committing sensitive data.
- Use the `terraform.tfvars` file for `dev`, `terraform.qa.tfvars` for `QA`, and `terraform.prod.tfvars` for `production` environments.
- Add `backend-config-*.hcl` files to `.gitignore` to avoid committing backend configuration files.

### Example `.gitignore` Entry:
```plaintext
# Ignore backend configuration files
backend-config-*.hcl
```

---

## Ansible Configuration

This project uses Ansible to configure the Jenkins server after provisioning the infrastructure with Terraform. The Ansible playbook installs necessary tools like Docker, Git, and Jenkins on the EC2 instance.

### Steps to Configure and Use Ansible

1. **Install Ansible**:
   Ensure that Ansible is installed on your local machine. If not, install it using the following command:
   ```bash
   sudo apt update
   sudo apt install ansible -y
   ```

2. Install Required Python Libraries: Install the boto3 and botocore Python libraries, which are required for the AWS EC2 dynamic inventory plugin:


pip install boto3 botocore  

3. Configure the Dynamic Inventory: The dynamic inventory is configured in the file ansible/inventory/aws_ec2.yml. Below is the configuration:

plugin: aws_ec2
regions:
  - aws-region
filters:
  tag:Name: ec2-instance-tag-name
keyed_groups:
  - key: tags.Name
    prefix: tag_Name_
compose:
  ansible_host: public_ip_address  

plugin: aws_ec2: Enables the AWS EC2 dynamic inventory plugin.
regions: Specifies the AWS region to query (e.g., eu-north-1).
filters: Filters EC2 instances based on the Name tag (e.g., Jenkins:Ubuntu-Linux-EC2).
compose: Ensures Ansible uses the public IP address for SSH connections. 

4. Update the Ansible Configuration: Ensure the ansible.cfg file is configured to use the dynamic inventory and the correct SSH key:
[defaults]
inventory = ./inventory/aws_ec2.yml
host_key_checking = False
remote_user = ubuntu
private_key_file = ssh key

[inventory]
enable_plugins = aws_ec2 

5. Test the Dynamic Inventory: Verify that the dynamic inventory is working and fetching the correct EC2 instances:

ansible-inventory -i ansible/inventory/aws_ec2.yml --list 

6. 
ansible -i ansible/inventory/aws_ec2.yml tag_Name__ec2_tag_name -m ping --private-key ~/.ssh/ssh-private-key --user ubuntu

7. Run the Ansible Playbook: Execute the Ansible playbook to configure Jenkins and other tools on the EC2 instance 

ansible-playbook -i ansible/inventory/aws_ec2.yml ansible/playbook/jenkins-setup.yml --private-key ~/.ssh/ssh-key --user ubuntu


---

## Architecture Diagram

+-----------------------------+
|         AWS Account         |
+-----------------------------+
            |
            v
+-----------------------------+
|           VPC              |
|  CIDR: 10.0.0.0/16         |
+-----------------------------+
    |                   |
    v                   v
+-----------+       +-----------+
| Public    |       | Private   |
| Subnets   |       | Subnets   |
| (2)       |       | (2)       |
+-----------+       +-----------+
    |                   |
    v                   v
+-----------------------------+
| Internet Gateway           |
+-----------------------------+
            |
            v
+-----------------------------+
| Application Load Balancer  |
| - HTTP (80)                |
| - HTTPS (443)              |
+-----------------------------+
            |
            v
+-----------------------------+
| Target Group               |
| - Port: 8080               |
+-----------------------------+
            |
            v
+-----------------------------+
| Jenkins EC2 Instance       |
| - Public IP Enabled        |
| - Security Groups:         |
|   - SSH (22), HTTP (80),   |
|     HTTPS (443), Jenkins   |
|     (8080)                 |
+-----------------------------+

+-----------------------------+
| Route 53 Hosted Zone        |
| - DNS Records               |
+-----------------------------+

+-----------------------------+
| ACM Certificate             |
| - SSL for HTTPS             |
+-----------------------------+

+-----------------------------+     
| S3 Bucket                   |
| - Stores Terraform State    |
| - Versioning Enabled        |
+-----------------------------+
https://github.com/user-attachments/assets/f481888c-decf-407a-b788-1dbdbcd7bc9f





