#!/bin/bash
# Pre-commit hook to format Terraform files

echo "Running Terraform format check..."
terraform fmt -recursive

# Add formatted files back to staging
git add -A

echo "Terraform files formatted successfully!"