# No seu environments/dev/backend/main.tf
data "aws_vpc" "dev" {
  filter {
    name   = "tag:Name"
    values = ["vpc-dev-economica"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dev.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*-public-*"] # O módulo da VPC nomeia as subnets assim por padrão
  }
}

# Obtém detalhes sobre a região configurada no provider
data "aws_region" "current" {}

# Obtém o ID da conta AWS (útil para ARNs de políticas)
data "aws_caller_identity" "current" {}
