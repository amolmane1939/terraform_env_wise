# Terraform CI/CD Pipeline Deployment Guide

## Overview
This guide will help you set up a complete CI/CD pipeline for your Terraform infrastructure using AWS CodePipeline, CodeBuild, and GitHub integration.

## Prerequisites
1. AWS CLI configured with appropriate permissions
2. Terraform installed locally
3. GitHub repository with your Terraform code
4. AWS account with necessary permissions

## Required AWS Permissions
Your AWS user/role needs the following permissions:
- CodePipeline full access
- CodeBuild full access
- IAM full access
- S3 full access
- CodeStar Connections full access

## Step-by-Step Deployment

### Step 1: Update Configuration
1. Navigate to the `CICD` directory:
   ```bash
   cd CICD
   ```

2. Edit `terraform.tfvars` and update the following values:
   ```hcl
   aws_region    = "us-east-1"                    # Your preferred AWS region
   github_repo   = "your-username/your-repo-name" # Your GitHub repository
   github_branch = "main"                         # Your main branch
   project_name  = "terraform-cicd"               # Your project name
   ```

### Step 2: Deploy CI/CD Infrastructure
1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the deployment:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

### Step 3: Configure GitHub Connection
After deployment, you need to complete the GitHub connection:

1. Go to AWS Console → Developer Tools → Settings → Connections
2. Find your connection (terraform-cicd-github-connection)
3. Click "Update pending connection"
4. Complete the GitHub authorization process
5. Select your repository and confirm

### Step 4: Pipeline Configuration Options

#### Option 1: Simple Single Environment Pipeline
- Uses the basic pipeline that deploys to dev environment
- Includes manual approval step
- Good for simple workflows

#### Option 2: Multi-Environment Pipeline
- Deploys to dev → stage → prod in sequence
- Automatic dev deployment
- Manual approvals for stage and prod
- Better for production workloads

### Step 5: Customize Build Specifications
The pipeline uses these buildspec files:
- `buildspec-plan-enhanced.yml` - For terraform plan
- `buildspec-apply-enhanced.yml` - For terraform apply

You can customize these files to:
- Add additional validation steps
- Include security scanning
- Add notification steps
- Modify environment variables

### Step 6: Environment Variables
Each CodeBuild project can have environment-specific variables:
- `TF_VAR_environment` - Target environment (dev/stage/prod)
- `AWS_DEFAULT_REGION` - AWS region for deployment

### Step 7: Testing the Pipeline
1. Push changes to your GitHub repository
2. Pipeline will automatically trigger
3. Monitor progress in AWS CodePipeline console
4. Approve manual approval steps when prompted

## Pipeline Stages Explained

### Source Stage
- Pulls code from GitHub repository
- Triggered on push to specified branch

### Plan Stage
- Runs `terraform plan`
- Validates configuration
- Generates execution plan
- Stores plan as artifact

### Approval Stage
- Manual approval step
- Review terraform plan output
- Approve or reject deployment

### Apply Stage
- Runs `terraform apply`
- Deploys infrastructure changes
- Stores outputs as artifacts

## Monitoring and Troubleshooting

### CloudWatch Logs
- Each CodeBuild project creates log groups
- View detailed execution logs
- Debug build failures

### S3 Artifacts
- Pipeline artifacts stored in S3 bucket
- Includes terraform plans and outputs
- Useful for debugging and auditing

### Common Issues
1. **GitHub Connection Pending**: Complete the connection setup in AWS Console
2. **Permission Errors**: Ensure CodeBuild role has necessary AWS permissions
3. **Terraform State**: Ensure proper state backend configuration
4. **Build Failures**: Check CloudWatch logs for detailed error messages

## Security Best Practices
1. Use least privilege IAM roles
2. Enable S3 bucket encryption
3. Store sensitive variables in AWS Systems Manager Parameter Store
4. Enable CloudTrail for audit logging
5. Use branch protection rules in GitHub

## Customization Options

### Adding Environments
To add new environments:
1. Create new CodeBuild projects
2. Add stages to pipeline
3. Create environment-specific buildspec files

### Adding Notifications
Add SNS notifications for:
- Pipeline success/failure
- Manual approval requests
- Build status updates

### Adding Security Scanning
Integrate tools like:
- Checkov for Terraform security scanning
- tfsec for static analysis
- AWS Config for compliance checking

## Cost Optimization
- Use smaller CodeBuild instance types for simple builds
- Enable S3 lifecycle policies for artifact cleanup
- Monitor CodeBuild usage and optimize build times

## Next Steps
1. Set up branch-based deployments
2. Add automated testing
3. Implement blue-green deployments
4. Add monitoring and alerting
5. Set up disaster recovery procedures

## Support
For issues or questions:
1. Check AWS CodePipeline documentation
2. Review CloudWatch logs
3. Validate IAM permissions
4. Test Terraform configurations locally first