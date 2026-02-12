output "pipeline_arn" {
  value       = aws_codepipeline.pipeline.arn
  description = "O ARN da esteira criada"
}

output "pipeline_url" {
  value       = "https://${var.aws_region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.pipeline.name}/view?region=${var.aws_region}"
  description = "Link direto para visualizar a esteira no console AWS"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.artifacts.id
}
