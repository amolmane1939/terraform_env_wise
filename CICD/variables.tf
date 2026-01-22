variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "github_repo" {
  description = "GitHub repository (owner/repo-name)"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to track"
  type        = string
  default     = "main"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-cicd"
}

variable "notification_email" {
  description = "Email address for pipeline notifications"
  type        = string
}