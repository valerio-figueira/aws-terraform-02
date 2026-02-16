variable "environment" {
  type        = string
  description = "Ambiente (develop, homolog, production)"
  default     = "develop"

  validation {
    condition     = contains(["develop", "homolog", "production"], var.environment)
    error_message = "environment deve ser develop, homolog ou production."
  }
}

variable "codestar_arn" {
  type        = string
  description = "ARN recebido pelo tfvars"
}

variable "repo_owner" {
  type        = string
  description = "Identificador do repositório"
}
