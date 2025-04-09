terraform {
  backend "s3" {
    bucket = "jenkins-tfstate-dev-2025"
    key    = "devops-project/jenkins/terraform.tfstate"
    region = "eu-north-1"
  }
}
