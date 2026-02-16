output "backend_services" {
  description = "Configurações dos serviços ECS"
  value = local.services_definition
}

output "lambda_functions" {
  description = "Configurações das funções Lambda"
  value = local.lambdas
}

output "codestar_arn" {
  description = "Amazon Resource Name (ARN) da conexão do Github"
  value = var.codestar_arn
}

output "repo_owner" {
  description = "Identificador do repositório"
  value       = var.repo_owner
}

output "branch_for_pipeline" {
  description = "Branch que dispara o pipeline (production -> main, demais -> mesmo nome)"
  value       = local.branch_for_pipeline
}
