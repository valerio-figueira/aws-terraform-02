# --- BUCKET S3 COM CARA DE EMPRESA ---
# O "estoque" temporário de arquivos do pipeline.
resource "aws_s3_bucket" "artifacts" {
  bucket        = "ecs-pipeline-${var.project_name}-${var.environment}-artifacts-${var.aws_account_id}"
  force_destroy = true # Cuidado em prod, aqui facilita a limpeza
}

# Mesmo que faças centenas de deploys de teste, o bucket nunca acumulará lixo por mais de 7 dias.
# ECONOMIA REAL: Deleta versões antigas automaticamente após 3 dias
resource "aws_s3_bucket_lifecycle_configuration" "artifacts_cleanup" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "delete_old_versions"
    status = "Enabled"

    filter {
      prefix = "" # Aplica-se a todos os objetos (artefatos de todos os microserviços)
    }

    noncurrent_version_expiration {
      noncurrent_days = 1 # Mantém versões antigas por apenas 1 dias
    }

    expiration {
      days = 7 # Deleta o objeto principal se ele ficar "órfão" por 7 dias
    }

    # Limpa uploads que falharam para não ocupar espaço "invisível"
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# Versionamento: Permite "Rollback" de artefatos
# CodePipeline exige versionamento 'Enabled'
resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled" # $0.023 por GB/mês + custo de armazenamento dobrado por versão.
  }
}

# Criptografia: Protege o código-fonte em repouso (Like Ninja)
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Use a chave padrão AES256 (S3 Managed Key), que é grátis.
    }
  }
}

# Bloqueio de acesso público (Segurança básica)
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
