#!/bin/bash

# Terraform CI/CD Pipeline Deployment Script

set -e

echo "🚀 Terraform CI/CD Pipeline Deployment Script"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "main.tf" ]; then
    echo "❌ Error: main.tf not found. Please run this script from the CICD directory."
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ Error: terraform.tfvars not found. Please create and configure it first."
    echo "📝 Copy terraform.tfvars.example and update with your values."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed or not in PATH."
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Error: AWS CLI is not configured or credentials are invalid."
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

echo ""

# Validate configuration
echo "🔍 Validating Terraform configuration..."
terraform validate

echo ""

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

echo ""

# Ask for confirmation
read -p "🤔 Do you want to proceed with the deployment? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Deploying CI/CD infrastructure..."
    terraform apply tfplan
    
    echo ""
    echo "✅ Deployment completed successfully!"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Go to AWS Console → Developer Tools → Settings → Connections"
    echo "2. Find your GitHub connection and complete the authorization"
    echo "3. Test the pipeline by pushing changes to your repository"
    echo ""
    echo "📊 Pipeline Details:"
    terraform output
else
    echo "❌ Deployment cancelled."
    rm -f tfplan
fi