locals {
  # Mapeamento: production usa branch "main", demais ambientes usam o próprio nome
  branch_for_pipeline = var.env == "production" ? "main" : var.env

  # --- Funções Lambda ---
  lambdas = {
    "api-fast-process" = {
      function_name = "lambda-api-fast-process-${var.env}"
      repo        = "${var.repo_owner}/aws-lambda"
      branch      = local.branch_for_pipeline
      memory_size = 128
      env_vars = {
        "NODE_ENV" = var.env
        "PORT"     = "3000"
      }
    }
  }
}
