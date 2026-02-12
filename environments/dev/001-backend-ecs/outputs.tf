output "pipeline_urls" {
  value       = { for k, v in module.pipeline_backend : k => v.pipeline_url }
  description = "URLs das esteiras de CI/CD por serviço"
}

output "services_info" {
  description = "Detalhes de rede e execução dos serviços ECS"
  value = {
    for k, s in aws_ecs_service.app : k => {
      service_name   = s.name
      cluster_name   = aws_ecs_cluster.main.name
      desired_count  = s.desired_count
      launch_type    = length(s.capacity_provider_strategy) > 0 ? "FARGATE_SPOT" : "FARGATE"
      security_group = aws_security_group.ecs_service_sg.id
    }
  }
}

# Comandos Úteis para Debug (Facilita muito a vida)
output "debug_commands" {
  description = "Comandos para monitoramento rápido via CLI"
  value = {
    for k, v in local.services : k => "aws logs get-log-events --log-group-name /ecs/${k}-${local.env} --log-stream-name $(aws logs describe-log-streams --log-group-name /ecs/${k}-${local.env} --query 'logStreams[0].logStreamName' --output text)"
  }
}

# Endereços IP (Apenas se estiver usando IP Público sem Load Balancer)
output "ecs_tasks_public_ips" {
  description = "Aviso: IPs de tarefas Fargate mudam a cada deploy. Use para testes rápidos."
  value       = "Para listar IPs: aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --service-name [nome-do-servico]"
}
