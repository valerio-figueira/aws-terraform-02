module "global_config" {
  source       = "../../../modules/global"
  env          = var.environment
  codestar_arn = var.codestar_arn
  repo_owner   = var.repo_owner
}

locals {
  env          = var.environment
  repo_owner   = var.repo_owner
  codestar_arn = var.codestar_arn
  lambdas      = module.global_config.lambda_functions
}
