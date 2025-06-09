output "debug_bucket_name" {
  value = var.bucket_name
}

# KMS key for S3 and DynamoDB encryption
resource "aws_kms_key" "terraform_encryption_key" {
  description             = "KMS key for Terraform state and DynamoDB encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "terraform-encryption-key"
  }
}

resource "aws_kms_alias" "terraform_encryption_key" {
  name          = "alias/terraform-encryption-key"
  target_key_id = aws_kms_key.terraform_encryption_key.key_id
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "jenkins-tfstate-dev-2024"  # Hardcoded value temporarily for testing

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "jenkins-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }

  # Enable server-side encryption with KMS
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.terraform_encryption_key.arn
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}
