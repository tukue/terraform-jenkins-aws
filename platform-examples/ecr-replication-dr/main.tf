resource "aws_ecr_replication_configuration" "platform" {
  replication_configuration {
    rule {
      destination {
        region      = var.destination_region
        registry_id = var.aws_account_id
      }

      repository_filter {
        filter      = var.repository_prefix
        filter_type = "PREFIX_MATCH"
      }
    }
  }
}
