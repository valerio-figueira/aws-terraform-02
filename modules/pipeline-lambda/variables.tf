variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "environment" {
  type        = string
  description = "Ambiente (develop, homolog, production)"

  validation {
    condition     = contains(["develop", "homolog", "production"], var.environment)
    error_message = "O environment deve ser develop, homolog ou production."
  }
}

variable "aws_account_id" {
  type        = string
  description = "ID da conta AWS injetado pelo root module"
}

variable "aws_region" {
  type        = string
  description = "Regiao do projeto"
  default     = "us-east-1"
}

variable "repo_id" {
  type        = string
  description = "ID do repositório (ex: usuario/repo)"
}

variable "branch_name" {
  type        = string
  description = "Branch que disparará o pipeline"

  validation {
    condition     = contains(["develop", "homolog", "main"], var.branch_name)
    error_message = "A branch_name deve ser develop, homolog ou main."
  }
}

variable "codestar_arn" {
  type        = string
  description = "O Amazon Resource Name (identificador único do recurso) da conexão do repositório"
}

variable "lambda_function_name" {
  type        = string
  description = "Nome da função Lambda que será atualizada"
}
