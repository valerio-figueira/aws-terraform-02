# --- REPOSITÓRIO ECR PARA O MICROSERVIÇO ---
# Lugar seguro e privado para armazenar imagens Docker. Custos: $0.10 por GB/mês.
# --- ECR: REPOSITÓRIO E LIMPEZA ---
resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256" # Grátis e seguro
  }
}

# Lifecycle do ECR para ambiente dev (economia)
resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Manter apenas 3 imagens"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 3
      }
      action = { type = "expire" }
    }]
  })
}
