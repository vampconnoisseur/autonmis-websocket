#!/bin/bash

send_update() {
    local step=$1
    local status=$2
    echo "{\"step\":\"$step\",\"status\":\"$status\"}"
}

if [ -z "$1" ] || [ -z "$2" ]; then
    send_update "error" "AWS region or username not provided."
    exit 1
fi

AWS_REGION=$1
USERNAME=$2

send_update "aws_validation" "AWS role validated successfully."

sleep 2

send_update "terraform_init" "Initializing Terraform..."
terraform init -backend-config="key=${USERNAME}/terraform.tfstate" -backend-config="region=${AWS_REGION}"

if [ $? -ne 0 ]; then
    send_update "terraform_init" "Terraform initialization failed."
    exit 1
fi
send_update "terraform_init" "Terraform initialized successfully."

steps=("network" "ecs" "autoscaling" "route53" "monitoring")

for step in "${steps[@]}"; do
    send_update "$step" "Applying Terraform for $step module in region $AWS_REGION with username $USERNAME..."
    
    case $step in
        network)
            terraform apply -target=module.network -var="region=$AWS_REGION" -var="username=$USERNAME" -auto-approve
            ;;
        ecs)
            terraform apply -target=module.ecs -var="region=$AWS_REGION" -var="username=$USERNAME" -auto-approve
            ;;
        autoscaling)
            terraform apply -target=module.autoscaling -var="region=$AWS_REGION" -var="username=$USERNAME" -auto-approve
            ;;
        route53)
            terraform apply -target=module.route53 -var="region=$AWS_REGION" -var="username=$USERNAME" -auto-approve
            ;;
        monitoring)
            terraform apply -target=module.monitoring -var="region=$AWS_REGION" -var="username=$USERNAME" -auto-approve
            ;;
    esac

    if [ $? -ne 0 ]; then
        send_update "$step" "$step module application failed."
        exit 1
    else
        send_update "$step" "$step module applied successfully."
    fi
done

send_update "all_steps" "All Terraform modules applied successfully."