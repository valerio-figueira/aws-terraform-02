module "pipeline_lambdas" {
  source = "../../../modules/pipeline-lambda"

  for_each     = local.lambdas
  project_name = each.key
  environment  = local.env

  # Nome da função que a esteira vai "atacar"
  lambda_function_name = each.value.function_name

  # Repositório e Branch
  repo_id      = each.value.repo
  branch_name  = each.value.branch
  codestar_arn = local.codestar_arn

  # Dados dinâmicos
  aws_region     = data.aws_region.current.id
  aws_account_id = data.aws_caller_identity.current.account_id
}
