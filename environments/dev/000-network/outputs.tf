# Output vindo do módulo de rede
output "vpc_dev" {
  description = "ID da VPC de Desenvolvimento"
  value       = module.vpc_dev.vpc_id
}
