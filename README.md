# AWS Fullstack Infrastructure as Code (IaC)

Este repositório contém a infraestrutura completa, automatizada e escalável para um ecossistema digital moderno na AWS. O projeto foca em **alta disponibilidade**, **segurança rigorosa** e **otimização de custos (FinOps)**, utilizando Terraform para gerenciar desde a rede fundamental até as esteiras de deploy contínuo.

## Arquitetura do Projeto

A solução foi desenhada seguindo o padrão de microserviços, dividida em camadas lógicas:

* **Networking (VPC):** Arquitetura multi-AZ com subnets públicas e privadas, otimizada para economia (sem custos fixos de NAT Gateway em ambiente de dev).
* **Compute (ECS Fargate & Lambda):** -   Cluster ECS rodando containers NestJS/Node.js com **Auto Scaling** (CPU e Memória).
* Serverless Functions (Lambda) para processamento sob demanda com lifecycle gerenciado.


* **Frontend:** Distribuição global via **CloudFront** com armazenamento estático em **S3**.
* **DevOps (CI/CD):** Pipelines automatizados via **AWS CodePipeline** e **CodeBuild**, integrando diretamente com GitHub/Bitbucket.

## Diferenciais Técnicos (Best Practices)

### 1. FinOps & Cost Optimization

* **ECS Fargate Spot:** Configuração preparada para uso de instâncias Spot, reduzindo custos em até 70%.
* **S3 & ECR Lifecycle:** Políticas automáticas que removem artefatos antigos e imagens Docker obsoletas, evitando acúmulo de custos de armazenamento.
* **CloudWatch Retention:** Logs configurados com retenção curta para ambientes de desenvolvimento.

### 2. Segurança (Security by Design)

* **Princípio de Menor Privilégio:** Roles de IAM customizadas e granulares para cada serviço.
* **Criptografia:** Artefatos em repouso protegidos por AES256.
* **Zero Hardcoded Credentials:** Uso intensivo de variáveis e Data Sources para isolamento de dados sensíveis.

### 3. Escalabilidade & Resiliência

* **Target Tracking Scaling:** O cluster reage automaticamente ao tráfego, mantendo a performance em picos de acesso.
* **Infra Estruturada em Módulos:** Código altamente reutilizável através de módulos Terraform para Pipelines, VPC e Frontend.

## Estrutura do Repositório

```bash
├── modules/               # Módulos reutilizáveis (Pipeline, Frontend, Global)
├── environments/
│   └── dev/               # Configurações do ambiente de Desenvolvimento
│       ├── vpc/           # Rede, Subnets e Gateways
│       ├── backend/       # ECS Cluster, Services e Autoscale
│       ├── lambdas/       # Funções Serverless e gatilhos
│       └── frontend/      # S3 Bucket e CloudFront Distribution

```

## Como Executar

1. **Pré-requisitos:**
* Terraform CLI instalado.
* AWS CLI configurado com as credenciais apropriadas.
* Uma conexão CodeStar criada manualmente no console AWS (para o GitHub).


2. **Inicialização:**
```bash
cd environments/dev/vpc
terraform init
terraform apply

```


3. **Deploy do Backend:**
```bash
cd ../backend
terraform init
terraform apply

```



## Tecnologias Utilizadas

* **IaC:** Terraform
* **Cloud:** Amazon Web Services (VPC, ECS, Lambda, S3, CloudFront, ECR, CodePipeline, IAM, CloudWatch)
* **Runtime:** Node.js / NestJS
* **Container:** Docker
