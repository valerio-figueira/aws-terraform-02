resource "aws_cloudwatch_log_group" "codebuild_lambda" {
  name              = "/aws/codebuild/${var.project_name}-${var.environment}-lambda"
  retention_in_days = 1 # Economia!
}
