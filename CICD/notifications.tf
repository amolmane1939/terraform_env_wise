# SNS Topic for Pipeline Notifications
resource "aws_sns_topic" "pipeline_notifications" {
  name = "${var.project_name}-pipeline-notifications"
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "pipeline_notifications" {
  arn = aws_sns_topic.pipeline_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.pipeline_notifications.arn
      }
    ]
  })
}

# Email Subscription (add your email)
resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.pipeline_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# EventBridge Rule for Pipeline State Changes
resource "aws_cloudwatch_event_rule" "pipeline_approval" {
  name = "${var.project_name}-pipeline-approval-rule"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      state = ["STARTED", "SUCCEEDED", "FAILED"]
      pipeline = [aws_codepipeline.terraform_multi_env_pipeline.name]
    }
  })
}

# EventBridge Rule for Manual Approval Actions
resource "aws_cloudwatch_event_rule" "manual_approval" {
  name = "${var.project_name}-manual-approval-rule"

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Stage Execution State Change"]
    detail = {
      state = ["STARTED"]
      pipeline = [aws_codepipeline.terraform_multi_env_pipeline.name]
      stage = ["Stage-Approval", "Prod-Approval"]
    }
  })
}

# EventBridge Target for Pipeline Events
resource "aws_cloudwatch_event_target" "pipeline_sns" {
  rule      = aws_cloudwatch_event_rule.pipeline_approval.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.pipeline_notifications.arn

  input_transformer {
    input_paths = {
      pipeline = "$.detail.pipeline"
      state    = "$.detail.state"
      region   = "$.region"
    }
    input_template = "\"Pipeline <pipeline> is now <state>. Check AWS Console: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/view?region=<region>\""
  }
}

# EventBridge Target for Approval Events
resource "aws_cloudwatch_event_target" "approval_sns" {
  rule      = aws_cloudwatch_event_rule.manual_approval.name
  target_id = "SendApprovalToSNS"
  arn       = aws_sns_topic.pipeline_notifications.arn

  input_transformer {
    input_paths = {
      pipeline = "$.detail.pipeline"
      stage    = "$.detail.stage"
      region   = "$.region"
    }
    input_template = "\"🚨 APPROVAL REQUIRED 🚨\\n\\nPipeline: <pipeline>\\nStage: <stage>\\n\\nAction Required: Manual approval needed to proceed with deployment.\\n\\nApprove here: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/<pipeline>/view?region=<region>\""
  }
}