# O CodePipeline precisa de uma role para poder ler o S3 e chamar o CodeBuild.
resource "aws_iam_role" "pipeline_role" {
  name = "${var.project_name}-${var.environment}-lambda-pipeline-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

# Esta é a role que vai executar o esbuild e o comando de deploy.
resource "aws_iam_role" "code_build_role" {
  name = "${var.project_name}-${var.environment}-lambda-build-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

# Permissões da Pipeline (Acesso ao S3 e CodeStar)
resource "aws_iam_role_policy" "pipeline_policy" {
  name = "pipeline_policy"
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject", "s3:GetBucketVersioning"]
        Resource = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
        Effect   = "Allow"
      },
      {
        Action   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action   = ["codestar-connections:UseConnection"]
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

# Permissões do CodeBuild (Logs, S3 e Deploy da Lambda)
resource "aws_iam_role_policy" "codebuild_lambda_policy" {
  name = "codebuild_policy"
  role = aws_iam_role.code_build_role.id

  policy = jsonencode({
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
        Effect   = "Allow"
      },
      {
        # ESSA É A PRINCIPAL: Permite atualizar o código da Lambda
        Action   = ["lambda:UpdateFunctionCode", "lambda:GetFunctionConfiguration"]
        Resource = "arn:aws:lambda:${var.aws_region}:${var.aws_account_id}:function:${var.lambda_function_name}"
        Effect   = "Allow"
      }
    ]
  })
}
