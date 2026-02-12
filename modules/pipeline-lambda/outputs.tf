output "pipeline_url" {
  value       = "https://${var.aws_region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.pipeline.name}/view?region=${var.aws_region}"
  description = "Link direto para a esteira da Lambda"
}

output "pipeline_arn" {
  value = aws_codepipeline.pipeline.arn
}
