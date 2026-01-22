# Multi-Environment CI/CD Pipeline Configuration

# Additional CodeBuild projects for different environments
resource "aws_codebuild_project" "terraform_plan_stage" {
  name         = "${var.project_name}-plan-stage"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "TF_VAR_environment"
      value = "stage"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-plan-enhanced.yml"
  }
}

resource "aws_codebuild_project" "terraform_apply_stage" {
  name         = "${var.project_name}-apply-stage"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "TF_VAR_environment"
      value = "stage"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-apply-enhanced.yml"
  }
}

resource "aws_codebuild_project" "terraform_plan_prod" {
  name         = "${var.project_name}-plan-prod"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "TF_VAR_environment"
      value = "prod"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-plan-enhanced.yml"
  }
}

resource "aws_codebuild_project" "terraform_apply_prod" {
  name         = "${var.project_name}-apply-prod"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "TF_VAR_environment"
      value = "prod"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec-apply-enhanced.yml"
  }
}

# Multi-Environment Pipeline
resource "aws_codepipeline" "terraform_multi_env_pipeline" {
  name     = "${var.project_name}-multi-env-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.github_repo
        BranchName       = var.github_branch
      }
    }
  }

  # Development Environment
  stage {
    name = "Dev-Plan"

    action {
      name             = "DevPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["dev_plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_plan.name
      }
    }
  }

  stage {
    name = "Dev-Deploy"

    action {
      name            = "DevDeploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_apply.name
      }
    }
  }

  # Staging Environment
  stage {
    name = "Stage-Plan"

    action {
      name             = "StagePlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["stage_plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_plan_stage.name
      }
    }
  }

  stage {
    name = "Stage-Approval"

    action {
      name     = "StageApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = "Please review the Staging deployment plan and approve to proceed."
      }
    }
  }

  stage {
    name = "Stage-Deploy"

    action {
      name            = "StageDeploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_apply_stage.name
      }
    }
  }

  # Production Environment
  stage {
    name = "Prod-Plan"

    action {
      name             = "ProdPlan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["prod_plan_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_plan_prod.name
      }
    }
  }

  stage {
    name = "Prod-Approval"

    action {
      name     = "ProdApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        CustomData = "PRODUCTION DEPLOYMENT - Please carefully review the production plan and approve only if ready for production deployment."
      }
    }
  }

  stage {
    name = "Prod-Deploy"

    action {
      name            = "ProdDeploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.terraform_apply_prod.name
      }
    }
  }
}