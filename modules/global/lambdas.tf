locals {
  # --- Funções Lambda ---
  lambdas = {
    "api-fast-process" = {
      function_name = "lambda-api-fast-process-${var.env}"
      repo        = "${var.repo_owner}/aws-lambda"
      branch      = var.env
      memory_size = 128
      env_vars = {
        "NODE_ENV" = var.env
        "PORT"     = "3000"
      }
    }
  }
}
