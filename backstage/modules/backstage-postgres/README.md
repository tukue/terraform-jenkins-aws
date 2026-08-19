# PostgreSQL RDS Module for Backstage

This module creates a PostgreSQL RDS instance for Backstage database.

## Usage

```hcl
module "backstage_postgres" {
  source = "./modules/backstage-postgres"

  environment       = "production"
  allocated_storage = 100
  instance_class    = "db.t3.medium"
  
  db_name  = "backstage"
  user     = "backstage_admin"

  subnet_ids             = module.vpc.private_subnet_ids
  security_group_ids     = [aws_security_group.backstage_db.id]
  
  backup_retention_days = 30
  multi_az              = true
  
  tags = {
    Environment = "production"
    Service     = "Backstage"
  }
}
```

## Outputs

- `db_endpoint` - Database endpoint
- `db_port` - Database port
- `db_name` - Database name
- `db_username` - Database username
- `db_resource_id` - RDS resource ID
- `master_user_secret_arn` - Secrets Manager secret ARN for the managed master password

## Variables

See `variables.tf` for complete list of variables.
