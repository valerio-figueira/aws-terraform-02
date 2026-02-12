# Build Artifact
resource "aws_codebuild_project" "build_artifact" {
  name         = "${var.project_name}-${var.environment}-build"
  service_role = aws_iam_role.code_build_role.arn

  artifacts { type = "CODEPIPELINE" }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true # Para executar os comandos Docker

    environment_variable {
      name  = "ACCOUNT_ID"
      value = var.aws_account_id
    }

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  source {
    type = "CODEPIPELINE"
    # A mágica acontece aqui: busca o arquivo baseado no stack_type
    buildspec = templatefile("${path.module}/templates/buildspec-artifact-${var.stack_type}.yml", {
      project_name = var.project_name
      environment  = var.environment
    })
  }

  # Para vincular o codebuild à VPC (opcional)
  #vpc_config {
  #  vpc_id             = var.vpc_id
  #  subnets            = var.public_subnet_ids
  #  security_group_ids = [aws_security_group.codebuild_sg.id]
  #}
}
