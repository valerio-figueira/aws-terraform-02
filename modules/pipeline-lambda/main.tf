resource "aws_codepipeline" "pipeline" {
  name          = "${var.project_name}-${var.environment}-pipeline"
  role_arn      = aws_iam_role.pipeline_role.arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  # Gatilho idêntico ao que se usa no ECS
  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = [var.branch_name]
        }
      }
    }
  }

  # ETAPA 1: Busca o código no GitHub/Bitbucket
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.codestar_arn
        FullRepositoryId = var.repo_id
        BranchName       = var.branch_name
        # Força a detecção automática de mudanças via Webhook
        DetectChanges = true
      }
    }
  }

  # ETAPA 2: Build + Deploy Automático
  # O CodeBuild faz o esbuild -> zip -> aws lambda update-function-code
  # WARNING: Separar Deploy para um novo stage para ambiente de produção (facilita rollbacks e visualização)
  stage {
    name = "Build_and_Deploy"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"
      configuration = {
        ProjectName = aws_codebuild_project.build_lambda.name
      }
    }
  }
}
