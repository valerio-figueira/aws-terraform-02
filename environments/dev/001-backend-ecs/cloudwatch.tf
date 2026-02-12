# CloudWatch Logs (Para debugar os micro-services)
resource "aws_cloudwatch_log_group" "ecs" {
  for_each          = local.services
  name              = "/ecs/${each.key}-${local.env}"
  retention_in_days = 3 # Economia: logs expiram em 3 dias
}
