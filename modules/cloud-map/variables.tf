variable "namespace_name" {
  type        = string
  description = "Nome do namespace DNS (ex: ecs.local)"
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC"
}

variable "environment" {
  type        = string
  description = "Ambiente (develop, homolog, production)"
}

variable "service_names" {
  type        = list(string)
  description = "Lista de nomes dos serviços ECS para registrar"
}
