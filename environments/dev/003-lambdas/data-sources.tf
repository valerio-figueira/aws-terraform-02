# Obtém detalhes sobre a região configurada no provider
data "aws_region" "current" {}

# Obtém o ID da conta AWS (útil para ARNs de políticas)
data "aws_caller_identity" "current" {}
