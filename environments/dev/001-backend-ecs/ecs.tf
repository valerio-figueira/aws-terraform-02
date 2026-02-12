# Cluster ECS (Econômico - Sem custos fixos)
resource "aws_ecs_cluster" "main" {
  name = "cluster-ecs-${local.env}"
}

# Security Group para o Serviço (Abrindo a porta do NestJS)
resource "aws_security_group" "ecs_service_sg" {
  name   = "ecs-service-sg-${local.env}"
  vpc_id = data.aws_vpc.dev.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Em prod, restringiríamos ao Load Balancer
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Task Definition e Service via Loop (para todos os seus serviços no local.services)
resource "aws_ecs_task_definition" "app" {
  for_each                 = local.services
  family                   = "${each.key}-${local.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256 # 0.25 vCPU (Mínimo para economizar)
  memory                   = 512 # 0.5 GB (Mínimo para economizar)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      # WARNING: Cuidado ao renomear o container pois poderá causar erros na pipeline
      # uma vez que a esteira utiliza o mesmo nome posto na "key":
      name      = each.key
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.id}.amazonaws.com/${each.key}-${local.env}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]

      # MÁGICA AQUI: Transforma o mapa env_vars em variáveis de ambiente do container
      environment = [
        for k, v in each.value.env_vars : {
          name  = k
          value = v
        }
      ]

      # Para segredos (AWS Secrets Manager)
      secrets = [
        for k, v in each.value.app_secrets : {
          name      = k
          valueFrom = v # ARN do Segredo na AWS
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${each.key}-${local.env}"
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  for_each        = local.services
  name            = each.key
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app[each.key].arn
  desired_count   = 1 # Apenas 1 instância para economizar em dev
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.public.ids
    security_groups = [aws_security_group.ecs_service_sg.id]
    # Acesso Direto: Como estamos em Subnets Públicas e não queremos pagar um NAT Gateway agora,
    # marcamos assign_public_ip = true. Isso permite que o container baixe a imagem do ECR e o 
    # Node.js baixe pacotes externos se precisar.
    assign_public_ip = true # Necessário se estiver em Subnet Pública sem NAT
  }
}

# Configuração de auto-scaling para o ECS
resource "aws_appautoscaling_target" "ecs_target" {
  for_each           = local.services
  max_capacity       = 2 # Limite máximo para não estourar orçamento (ambiente dev)
  min_capacity       = 1 # Mantém pelo menos 1 instância (conforme seu desejado atual) 
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Política de Escalonamento por CPU: A forma mais econômica e inteligente de escalar é o Target Tracking
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  for_each           = local.services
  name               = "track-cpu-${each.key}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0 # Tenta manter o uso de CPU em 70%
    scale_in_cooldown  = 300  # Espera 5 min antes de desligar uma instância (evita instabilidade)
    scale_out_cooldown = 60   # Espera apenas 1 min para subir uma nova (rapidez na resposta)

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# Política de Escalonamento por Memória (Crucial para Node.js)
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  for_each           = local.services
  name               = "track-memory-${each.key}-${local.env}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 80.0 # Node.js geralmente aguenta um pouco mais de memória antes de gargalar
    scale_in_cooldown  = 300
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}
