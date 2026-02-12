module "frontend" {
  source      = "../../modules/frontend"
  bucket_name = "app-vue-dev" # Mude para cada ambiente
  env         = "dev"
  price_class = "PriceClass_100" # Mais barato para dev
}
