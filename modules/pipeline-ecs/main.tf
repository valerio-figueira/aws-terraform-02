resource "aws_codepipeline" "pipeline" {
  name          = "${var.project_name}-${var.environment}-pipeline"
  role_arn      = aws_iam_role.pipeline_role.arn
  pipeline_type = "V2" # WARNING: Necessário para adicionar o trigger

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

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

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection" # Recomendado para GitHub/Bitbucket
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn    = var.codestar_arn # Criar manualmente no console uma vez
        FullRepositoryId = var.repo_id
        BranchName       = var.branch_name
        # Força a detecção automática de mudanças via Webhook
        DetectChanges = true
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]

      # Quando o CodeBuild termina com sucesso, o CodePipeline pega os arquivos
      # listados na seção artifacts do buildspec (no caso, o imagedefinitions.json), 
      # compacta-os em um .zip e os salva no bucket S3 de artefatos com um nome aleatório controlado internamente.
      output_artifacts = ["build_output"]
      version          = "1"
      configuration    = { ProjectName = aws_codebuild_project.build_artifact.name }
    }
  }

  # CodePipeline fala diretamente com o ECS:
  stage {
    name = "Deploy"
    action {
      name     = "Deploy"
      category = "Deploy" # Mudança de Build para Deploy
      owner    = "AWS"
      provider = "ECS" # Provedor nativo

      # O CodePipeline "sabe" que o nome (build_output) refere-se ao resultado da etapa anterior. 
      # Antes de iniciar o CodeBuild de deploy, o Pipeline vai até o S3, 
      # baixa aquele .zip e descompacta-o dentro do ambiente temporário do CodeBuild.
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = var.cluster_name
        ServiceName = var.project_name
        FileName    = "imagedefinitions.json" # Lê o JSON sozinho!
      }
    }
  }
}
