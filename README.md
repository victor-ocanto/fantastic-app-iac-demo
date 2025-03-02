# Fantastic App IaC demo

## Description
This repository contains Terraform code to provision and manage a demo app running on EKS

- **EKS**: For hosting the application

The code is modular and reusable, making it easy to deploy and maintain infrastructure across multiple environments.


---

## Getting Started
### Prerequisites
- **Terraform**: Version 1.0.0 or later.
- **AWS CLI**: Configured with appropriate credentials.
- AWS account with permissions to create the necessary resources.
- An instance of Consul Vault running and set ENV vars like:
  - export VAULT_ADDR="http://127.0.0.1:8200"
  - export VAULT_TOKEN="your token" 
- Set env variable on Terraform workstation: 
  - export TF_VAR_aws_account_id="your account id"
- Create and use Terraform Workspace
  - terraform workspace new dev
  - terraform workspace select dev
- Terraform Remote Backend with AWS. the terraform-backend-CloudFormation.yml file creates the backend in AWS
  - aws cloudformation create-stack --stack-name TerraformBackend --template-body file://terraform-backend-CloudFormation.yml --capabilities CAPABILITY_NAMED_IAM


