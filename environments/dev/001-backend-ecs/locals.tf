module "global_config" {
  source       = "../../../modules/global"
  env          = var.environment
  codestar_arn = var.codestar_arn
  repo_owner   = var.repo_owner
}

locals {
  env               = var.environment
  branch_for_pipeline = module.global_config.branch_for_pipeline
  repo_owner        = var.repo_owner
  codestar_arn      = var.codestar_arn
  services          = module.global_config.backend_services
}
