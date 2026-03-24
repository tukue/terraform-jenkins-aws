terraform {
  source = "./"
}

locals {
  environment    = get_env("TF_ENVIRONMENT", "dev")
  aws_region     = get_env("AWS_REGION", "eu-north-1")
  aws_account_id = get_env("AWS_ACCOUNT_ID", "")
  state_key      = "terraform/${local.environment}/terraform.tfstate"
}

remote_state {
  backend = "s3"

  config = {
    bucket         = "jenkins-tfstate-platform"
    key            = local.state_key
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "jenkins-terraform-locks"
  }
}

inputs = {
  environment    = local.environment
  aws_region     = local.aws_region
  aws_account_id = local.aws_account_id
}
