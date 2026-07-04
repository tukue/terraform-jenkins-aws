bucket         = "jenkins-tfstate-platform"
key            = "live/prod/terraform.tfstate"
region         = "eu-north-1"
encrypt        = true
dynamodb_table = "jenkins-terraform-locks"
