bucket         = "customer-ecs-runtime-tfstate"
key            = "customer/acme/qa/terraform.tfstate"
region         = "eu-north-1"
encrypt        = true
dynamodb_table = "customer-ecs-runtime-locks"
