# Role do CodePipeline
# Entidade que pode assumir a Role (Trust Policy)
resource "aws_iam_role" "pipeline_role" {
  name = "${var.project_name}-${var.environment}-pipeline-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

# Permissões da Pipeline (Acesso ao S3 de artefatos e disparar CodeBuild)
resource "aws_iam_role_policy" "pipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.pipeline_role.id

  policy = jsonencode({
    Statement = [
      # Adiciona permissões do S3:
      {
        Action   = ["s3:GetObject", "s3:PutObject", "s3:GetBucketVersioning"]
        Resource = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
        Effect   = "Allow"
      },
      # Permissões do CodeBuild:
      {
        Action   = ["codebuild:BatchGetBuilds", "codebuild:StartBuild"]
        Resource = "*"
        Effect   = "Allow"
      },
      # Permissões para a pipeline poder se conectar com Github/Bitbucket, etc:
      {
        Action   = ["codestar-connections:UseConnection"]
        Resource = "*"
        Effect   = "Allow"
      },
      # Como o CodePipeline agora é quem faz o deploy (e não mais o CodeBuild via CLI), 
      # a Role da Pipeline precisa de permissão para falar com o ECS:
      {
        Action = [
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      # Passar o Bastão: autorizar o CodePipeline a pegar a Role de execução da tarefa
      # e entregá-la para o ECS para que ele possa subir os containers.
      {
        Action   = "iam:PassRole"
        Resource = "*"
        Effect   = "Allow"
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Role do CodeBuild
# Esta é a role crítica.
resource "aws_iam_role" "code_build_role" {
  name = "${var.project_name}-${var.environment}-build-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

# Permissões básicas de Logs e S3
resource "aws_iam_role_policy" "build_common_policy" {
  name = "codebuild_common_policy"
  role = aws_iam_role.code_build_role.id

  policy = jsonencode({
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action   = ["s3:GetObject", "s3:PutObject", "s3:GetBucketVersioning"]
        Resource = [aws_s3_bucket.artifacts.arn, "${aws_s3_bucket.artifacts.arn}/*"]
        Effect   = "Allow"
      }
    ]
  })
}

# Permissões para o CodeBuild interagir com o ECR
resource "aws_iam_role_policy" "build_ecr_policy" {
  name = "codebuild_ecr_policy"
  role = aws_iam_role.code_build_role.id

  policy = jsonencode({
    Statement = [
      {
        # 1. Permissão para fazer Login (é global, não aceita ARN de repositório específico)
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        # 2. Permissões de escrita e leitura no repositório específico
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = [aws_ecr_repository.app.arn]
        Effect   = "Allow"
      }
    ]
  })
}
