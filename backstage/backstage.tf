# PostgreSQL RDS Instance
module "backstage_postgres" {
  source = "./modules/backstage-postgres"

  environment           = var.environment
  allocated_storage     = var.db_allocated_storage
  instance_class        = var.db_instance_class
  backup_retention_days = var.db_backup_retention
  multi_az              = var.environment == "prod" ? true : false

  db_name  = "backstage"
  user     = "backstage_admin"

  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.backstage_db.id]

  publicly_accessible = false
  skip_final_snapshot = var.environment != "prod"

  tags = var.tags
}

# Backstage EC2 Instance
module "backstage_ec2" {
  source = "./modules/backstage-ec2"

  environment      = var.environment
  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size
  key_name         = var.key_name != "" ? var.key_name : null

  subnet_id            = module.vpc.public_subnets[0]
  security_group_ids   = [aws_security_group.backstage.id]
  iam_instance_profile = aws_iam_instance_profile.backstage.name

  # Database configuration
  db_host     = module.backstage_postgres.db_address
  db_port     = module.backstage_postgres.db_port
  db_name     = "backstage"
  db_user     = "backstage_admin"
  db_password_secret_arn = module.backstage_postgres.master_user_secret_arn

  # GitHub integration
  github_client_id     = var.github_client_id
  github_client_secret = var.github_client_secret
  github_token         = var.github_token
  aws_region           = var.aws_region

  backstage_version = var.backstage_version

  tags = var.tags

  depends_on = [
    module.backstage_postgres,
    aws_iam_role_policy.backstage_secrets
  ]
}
