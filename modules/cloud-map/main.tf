# Namespace DNS privado (ex: ecs.local)
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = var.namespace_name
  description = "Service discovery namespace for ECS - ${var.environment}"
  vpc         = var.vpc_id
}

# Service Discovery por ECS service
resource "aws_service_discovery_service" "ecs" {
  for_each = toset(var.service_names)

  name = each.value

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  # Para Fargate: sem Route53 health check (usa custom; threshold fixo em 1 na API AWS)
  health_check_custom_config {}
}
