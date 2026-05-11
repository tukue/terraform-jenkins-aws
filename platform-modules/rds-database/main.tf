resource "aws_db_instance" "this" {
  identifier                  = var.identifier
  allocated_storage           = var.allocated_storage
  storage_type                = var.storage_type
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  db_name                     = var.db_name
  username                    = var.username
  manage_master_user_password = true
  parameter_group_name        = var.parameter_group_name
  skip_final_snapshot         = var.skip_final_snapshot
  publicly_accessible         = var.publicly_accessible
  storage_encrypted           = true
  kms_key_id                  = var.kms_key_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  db_subnet_group_name        = var.db_subnet_group_name

  tags = merge(
    var.tags,
    {
      Name        = var.identifier
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_db_subnet_group" "this" {
  count      = var.create_db_subnet_group ? 1 : 0
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name        = "${var.identifier}-subnet-group"
      Environment = var.environment
    }
  )
}
