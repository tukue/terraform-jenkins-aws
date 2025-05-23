terraform {
  backend "s3" {
    bucket         = "jenkins-tfstate-dev-2025"
    key            = "terraform/dev/terraform.tfstate"
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "jenkins-terraform-locks"
  }
}