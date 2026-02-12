variable "env" {
  type = string

  validation {
    condition     = contains(["develop", "homolog", "production"], var.env)
    error_message = "A variável env deve ser develop, homolog ou production."
  }
}

variable "codestar_arn" {
  type = string
  description = "ARN da conexão CodeStar (Github/Bitbucket)"
}

variable "repo_owner" {
  type = string
  description = "Identificador do repositório"
}
