# Bucket S3 para os arquivos estáticos
resource "aws_s3_bucket" "frontend" {
  bucket = var.bucket_name
  tags   = { Name = "Frontend-${var.env}", Environment = var.env }
}

# Configura o bucket para permitir que o CloudFront o acesse. 
# Evita que alguém acesse os arquivos diretamente pela URL do S3.
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Política do Bucket para permitir acesso do CloudFront (OAC)
resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]

    # O serviço CloudFront da AWS é o único que pode tentar realizar a ação acima.
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    # Esta é a camada extra de segurança (muito importante!). 
    # Sem essa condição, qualquer pessoa que criasse um CloudFront na conta dela poderia tentar ler seus arquivos.
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}
