resource "aws_lambda_function" "app" {
  for_each      = local.lambdas
  function_name = each.value.function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"

  # Placeholder: Um arquivo zip vazio só para o Terraform conseguir criar a função
  # Na primeira execução da esteira, esse código será substituído pelo real.
  filename = "${path.module}/placeholder.zip"

  memory_size = each.value.memory_size
  timeout     = 10

  lifecycle {
    ignore_changes = [filename, source_code_hash] # WARNING: Impede o Terraform de dar "downgrade" no código que a esteira subiu (vital)
  }

  environment {
    variables = merge(
      {
        NODE_ENV = local.env # Define o padrão baseado no local.env (develop/prod)
      },
      each.value.env_vars # Permite sobrescrever ou adicionar novas variáveis
    )
  }
}
