variable "bucket_name" {
  description = "Nome único do bucket S3"
  type        = string
}

variable "env" {
  description = "Ambiente (dev, hml, prod)"
  type        = string
}

variable "price_class" {
  description = "Classe de preço do CloudFront (PriceClass_100, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
}
