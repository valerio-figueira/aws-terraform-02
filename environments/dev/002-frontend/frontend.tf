module "frontend" {
  source      = "../../modules/frontend"
  bucket_name = "app-vue-dev-${data.aws_caller_identity.current.account_id}"
  env         = "dev"
  price_class = "PriceClass_100" # Mais barato para dev
}
