# Outputs vindo do módulo de frontend
output "frontend_url" {
  description = "URL do CloudFront para acessar o App Vue"
  value       = module.frontend.cloudfront_url
}

output "cloudfront_distribution_id" {
  description = "ID da distribuição (usado para invalidar cache no CI/CD)"
  value       = module.frontend.cloudfront_id
}
