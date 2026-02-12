resource "aws_codebuild_project" "build_lambda" {
  name         = "${var.project_name}-${var.environment}-build"
  service_role = aws_iam_role.code_build_role.arn

  artifacts { type = "CODEPIPELINE" }

  environment {
    # 'BUILD_LAMBDA_1GB' é a computação mais barata do CodeBuild (paga-se menos por minuto)
    compute_type = "BUILD_LAMBDA_1GB"

    # Imagem baseada em ARM64 (Graviton) - 20% mais barata que x86
    image = "aws/codebuild/amazonlinux-aarch64-lambda-standard:nodejs22"

    # Tipo de container específico para runtimes Lambda
    type = "ARM_LAMBDA_CONTAINER"

    privileged_mode = false # Lambda não precisa de Docker/Privilegiado

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "NODE_ENV"
      value = var.environment
    }

    environment_variable {
      name  = "LAMBDA_FUNCTION_NAME"
      value = var.lambda_function_name
    }
  }

  # Lança logs no cloudwatch para monitorias
  #logs_config {
  #  cloudwatch_logs {
  #    group_name = aws_cloudwatch_log_group.codebuild_lambda.name
  #  }
  #}

  source {
    type = "CODEPIPELINE"
    # Aponta para o buildspec específico de Lambda que criamos na etapa anterior
    buildspec = templatefile("${path.module}/templates/buildspec-lambda.yml", {
      lambda_name = var.lambda_function_name
    })
  }
}
