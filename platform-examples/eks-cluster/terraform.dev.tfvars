aws_region             = "eu-north-1"
aws_account_id         = "123456789012"
cluster_name           = "my-platform"
environment            = "dev"
kubernetes_version     = "1.31"
enable_lb_controller   = true
endpoint_public_access = true

tags = {
  Environment = "dev"
  Owner       = "platform-team"
  Tier        = "nonprod"
}
