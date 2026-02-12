module "vpc_dev" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-dev-economica"
  cidr = "10.0.0.0/16"

  # Definindo as Zonas de Disponibilidade
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]

  # --- CONFIGURAÇÃO DE ECONOMIA MÁXIMA ---

  # Desativa NAT Gateways (Economiza ~$32 por mês por gateway)
  # Nota: Suas instâncias na subnet privada NÃO terão internet sem NAT.
  # Para estudos, coloque suas instâncias na 'public_subnet'.
  enable_nat_gateway = false
  single_nat_gateway = false

  # Desativa VPN Gateway (Recurso pago)
  enable_vpn_gateway = false

  # Ativa nomes DNS (Geralmente gratuito e essencial)
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "estudo-aws"
  }
}
