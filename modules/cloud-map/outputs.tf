output "namespace_id" {
  description = "ID do namespace Cloud Map"
  value       = aws_service_discovery_private_dns_namespace.main.id
}

output "namespace_name" {
  description = "Nome do namespace (para injetar em env vars)"
  value       = aws_service_discovery_private_dns_namespace.main.name
}

output "service_registry_arns" {
  description = "Mapa service_name -> ARN do Service Discovery"
  value       = { for k, v in aws_service_discovery_service.ecs : k => v.arn }
}
