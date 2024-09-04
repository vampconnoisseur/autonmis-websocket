#!/bin/bash

# Function to send updates via echo (stdout), which the Node.js server will capture
send_update() {
    local step=$1
    local status=$2
    echo "{\"step\":\"$step\",\"status\":\"$status\"}"
}

# Validate input parameters
if [ -z "$1" ] || [ -z "$2" ]; then
    send_update "error" "AWS region or username not provided. Please pass the AWS region as the first argument and username as the second argument."
    exit 1
fi

AWS_REGION=$1
USERNAME=$2

send_update "aws_region" "AWS Region: $AWS_REGION"
send_update "username" "Username: $USERNAME"

# Initialize Terraform with the provided AWS region and username
send_update "terraform_init" "Initializing Terraform..."
terraform init -backend-config="key=${USERNAME}/terraform.tfstate" -backend-config="region=${AWS_REGION}"

if [ $? -ne 0 ]; then
    send_update "terraform_init" "Terraform initialization failed."
    exit 1
fi

send_update "terraform_init" "Terraform initialized successfully."

# Destroy Terraform-managed infrastructure with username variable
send_update "terraform_destroy" "Destroying Terraform-managed infrastructure..."
terraform destroy -var="region=$AWS_REGION" -var="username=$USERNAME" -auto-approve

if [ $? -ne 0 ]; then
    send_update "terraform_destroy" "Terraform destroy failed."
    exit 1
else
    send_update "terraform_destroy" "Terraform destroy completed successfully."
fi

send_update "completed" "Terraform destroy process completed."