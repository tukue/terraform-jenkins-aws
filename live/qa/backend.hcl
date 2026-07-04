bucket         = "jenkins-tfstate-platform"
key            = "live/qa/terraform.tfstate"
region         = "eu-north-1"
encrypt        = true
dynamodb_table = "jenkins-terraform-locks"
