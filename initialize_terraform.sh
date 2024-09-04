#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <region> <username>"
    exit 1
fi

REGION=$1
USERNAME=$2

rm -rf .terraform .terraform.lock.hcl

cat <<EOF > backend.tf
terraform {
  backend "s3" {
    bucket = "user-backend-config-files"
    key    = "${USERNAME}/terraform.tfstate"
    region = "${REGION}"
  }
}
EOF

echo "Backend configuration:"
cat backend.tf

terraform init -reconfigure