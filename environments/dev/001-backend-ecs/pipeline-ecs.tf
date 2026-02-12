module "pipeline_backend" {
  source = "../../../modules/pipeline-ecs"

  for_each     = local.services
  project_name = each.key
  repo_id      = each.value.repo
  stack_type   = each.value.stack

  environment  = local.env
  branch_name  = local.env
  codestar_arn = local.codestar_arn

  # Dados dinâmicos obtidos via Data Sources
  aws_region     = data.aws_region.current.id
  aws_account_id = data.aws_caller_identity.current.account_id

  cluster_name = aws_ecs_cluster.main.name # Referência ao cluster criado no ecs.tf

  # Para vincular o codebuild à vpc (opcional)
  # Private Subnet: Será necessário ativar o NAT para ter acesso ao Repositório (Github) e baixar dependências de Back-end
  # Public Subnet: Pode ter problemas para acessar a internet via NAT
  # No momento essa pipeline não será adicionada à VPC pelos custos de desenvolvimento
  vpc_id            = data.aws_vpc.dev.id
  public_subnet_ids = data.aws_subnets.public.ids
}
