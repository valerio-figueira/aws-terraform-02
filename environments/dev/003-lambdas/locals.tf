module "global_config" {
  source     = "../../../modules/global"
  env        = local.env
  codestar_arn = var.codestar_arn
  repo_owner = var.repo_owner
}

locals {
  env          = "develop"
  repo_owner   = module.global_config.repo_owner
  codestar_arn = module.global_config.codestar_arn
  lambdas      = module.global_config.lambda_functions  
}
