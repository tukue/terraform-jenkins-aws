aws_region             = "eu-north-1"
aws_account_id         = "123456789012"
cluster_name           = "my-platform"
environment            = "prod"
kubernetes_version     = "1.31"
enable_lb_controller   = true
endpoint_public_access = false

tags = {
  Environment = "prod"
  Owner       = "platform-team"
  Tier        = "production"
}
