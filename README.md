# Terraform Project: EC2 & S3 with IAM Role and Remote State Backend

This Terraform project provisions an EC2 instance and an S3 bucket, creates and attaches an IAM role to the EC2 instance to allow secure access to the S3 bucket, and stores the Terraform state file remotely in S3 using the backend concept.
The project follows Terraform best practices, uses a module-based structure, and is deployed using the dev workspace.

## Features

- **EC2 Instance**
  - Provisions an EC2 instance using a reusable module.
  - Configurable AMI, instance type, key pair, and SSH access.
  - IAM role attached via instance profile.

- **S3 Bucket**
  - Created using a separate reusable module.
  - Used for application access and Terraform remote state storage.
  - IAM Role & Policy
  - EC2-assumable IAM role.
  - Least-privilege IAM policy scoped to a specific S3 bucket only.

- **Remote Backend**
  - Terraform state stored securely in S3.
  - No DynamoDB used (as per requirement).

- **Terraform Workspaces**
  - Uses dev workspace for environment isolation.
  - Workspace-aware resource naming.

## Best Practices
  - Latest Terraform version.
  - Provider configuration in a separate file.
  - Module-based architecture.
  - Variables used for safe and configurable inputs.

## Prerequisites

Before using this project, ensure you have the following installed and configured:

1. Terraform (latest version)
2. AWS CLI
3. AWS credentials configured (aws configure)
4. An existing SSH key pair in AWS
5. S3 bucket created manually for Terraform backend (initial setup only)

## Project Structure
```sh
.
├── backend.tf
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── terraform.tfstate.d
│   └── dev
│       ├── terraform.tfstate
│       └── terraform.tfstate.backup
├── modules
│   ├── ec2
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── s3
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── README.md
```

## Terraform Backend Configuration (S3)

The Terraform state is stored remotely in an S3 bucket using the backend configuration defined in `backend.tf`.
```hcl
terraform {
  backend "s3" {
    bucket  = "codingcops-terraform-state-dev"
    key     = "terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
```
**Note:**
The backend S3 bucket must be created manually before running terraform init.

After configuring the backend:
```sh
terraform init -migrate-state
```
## Terraform Workspaces

This project uses Terraform workspaces to manage environments.

Create and switch to the dev workspace:
```sh
terraform workspace new dev
terraform workspace select dev
```
All resources are created under the dev workspace.

## Module Inputs
Root Module Variables
```sh
project_name      = "Project name used for resource naming"
aws_region        = "AWS region where resources will be created (e.g., ap-south-1)"
ami_id            = "AMI ID for the EC2 instance"
instance_type     = "EC2 instance type (e.g., t2.micro)"
key_name          = "Existing AWS key pair name"
allowed_ssh_cidr  = "CIDR block allowed for SSH access"
s3_bucket_name    = "Base name for the S3 bucket"
```
Values are safely passed using `terraform.tfvars`.

## Module Outputs
```sh
s3_bucket_name = "Name of the S3 bucket created"
s3_bucket_arn  = "ARN of the S3 bucket"
ec2_instance_id        = "ID of the EC2 instance"
ec2_instance_public_ip = "Public IP address of the EC2 instance"
ec2_instance_private_ip = "Private IP address of the EC2 instance"
iam_role_arn = "ARN of the IAM role attached to the EC2 instance"
workspace = "Current Terraform workspace in use"
```

## Project Setup
1. Clone the Repository
```sh
git clone https://github.com/Dawood-Usman/terraform-ec2-s3-example
cd terraform-project
```
3. Initialize Terraform
```sh
terraform init
```
4. Validate Configuration
```sh
terraform fmt
terraform validate
```
5. Review the Execution Plan
```sh
terraform plan
```
6. Deploy Resources
```sh
terraform apply
```
## Verify the Deployment
1. Verify EC2 Access
```sh
ssh ec2-user@<ec2-public-ip>
```
2. Verify IAM Role Attachment
```sh
aws sts get-caller-identity
```
3. Verify S3 Access from EC2
```sh
aws s3 ls s3://<s3-bucket-name>
```
## Cleaning Up
To destroy all resources created in the dev workspace:
```sh
terraform destroy
```
⚠️ **Note:**
For development environments, the S3 bucket is configured to allow clean teardown.
