# -----------------------------
# Random suffix for globally unique S3 bucket name
# -----------------------------
# resource "random_id" "bucket_suffix" {
#   byte_length = 4
# }

# -----------------------------
# S3 Bucket for Terraform State
# -----------------------------
resource "aws_s3_bucket" "terraform_state" {
  bucket = "rifkhan-terraform-devops-states"

  tags = {
    Name        = "terraform-devops-state"
    Project     = "terraform-devops"
    Environment = "shared"
  }
}

# -----------------------------
# Enable Versioning on State Bucket
# -----------------------------
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------
# Enable Server-Side Encryption
# -----------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------
# Block Public Access
# -----------------------------
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------
# DynamoDB Table for Terraform State Locking
# -----------------------------
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "rifkhan-terraform-devops-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "terraform-devops-locks"
    Project     = "terraform-devops"
    Environment = "shared"
  }
}