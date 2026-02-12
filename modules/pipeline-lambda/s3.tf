# --- BUCKET S3 PARA ARTEFATOS DA LAMBDA ---
# Aqui ficarão os arquivos function.zip temporários
resource "aws_s3_bucket" "artifacts" {
  bucket        = "lambda-pipeline-${var.project_name}-${var.environment}-${var.aws_account_id}"
  force_destroy = true # Importante para facilitar o 'terraform destroy' em estudos
}

# --- ECONOMIA AGRESSIVA: LIMPEZA AUTOMÁTICA ---
# Diferente do ECS, o ZIP da Lambda pode ocupar alguns MBs. 
# Vamos deletar TUDO que tiver mais de 1 dias para não acumular custo.
resource "aws_s3_bucket_lifecycle_configuration" "artifacts_cleanup" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "fast-cleanup-lambda"
    status = "Enabled"

    filter {
      prefix = ""
    }

    # Como a Lambda é atualizada e o código já fica na AWS Lambda, 
    # não precisamos guardar o ZIP no S3 por muito tempo.
    expiration {
      days = 1 # Deleta o objeto principal após 1 dias
    }

    noncurrent_version_expiration {
      noncurrent_days = 1 # Deleta versões antigas quase que imediatamente
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

# CodePipeline EXIGE que o versionamento esteja ativado
resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
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
