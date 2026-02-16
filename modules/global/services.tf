locals {
  # --- Serviços Back-end ---
  services_definition = {
    "backend-nest-app-1" = {
      repo           = "${var.repo_owner}/nest-app"
      stack          = "nodejs"
      port           = 3000
      env_vars = {
        "NODE_ENV" = var.env
        "PORT"     = "3000"
        "ECS_SERVICE_DISCOVERY_DOMAIN" = "ecs.local"  # Para construir URLs
      }
      # TO-DO: Para segredos (AWS Secrets Manager)
      app_secrets = []
    }
    # Outros serviços seriam adicionados aqui...
  }
}
