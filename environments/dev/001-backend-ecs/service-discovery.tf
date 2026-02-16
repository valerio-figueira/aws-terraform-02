module "cloud_map" {
  source = "../../../modules/cloud-map"

  namespace_name = "ecs.local"
  vpc_id         = data.aws_vpc.dev.id
  environment    = local.env

  # Extrai nomes dos serviços do local.services (keys do map)
  service_names = [for k, _ in local.services : k]
}
