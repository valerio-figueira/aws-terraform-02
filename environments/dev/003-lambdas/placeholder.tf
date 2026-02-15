# Placeholder zip gerado automaticamente para criação inicial da Lambda.
# Na primeira execução da pipeline, o código real substitui este placeholder.
data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/placeholder.zip"
  source {
    content  = "{}"
    filename = "placeholder.json"
  }
}
